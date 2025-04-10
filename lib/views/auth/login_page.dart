import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/core/services/auth_service.dart';
import 'package:ui_trangsuc_vs2/views/auth/forget_pass.dart';
import 'package:ui_trangsuc_vs2/views/auth/register_page.dart';
import 'package:ui_trangsuc_vs2/main.dart'; // 🔥 Import MainScreen
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart'; // Import UserPreferences

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState(); // 🔥 Đúng cú pháp
}

class _LoginPageState extends State<LoginPage> { // 🔥 Đặt dấu `_` trước class
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  /// 🛠 **Xử lý đăng nhập**
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Vui lòng nhập đầy đủ email & mật khẩu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.fetchLogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
      );

      if (response["success"] == true) {
        String userName = response["user"]["name"] ?? "Guest";
        String phone = response["user"]["phone"] ?? "N/A"; 
        String address = response["user"]["address"] ?? "Unknown";
        String email = response["user"]["email"] ?? "No Email";
        String token = response["token"] ?? "";
        String idNguoidung = response["user"]["id"] ?? "";

        // ✅ **Lưu trạng thái đăng nhập vào SharedPreferences**
        await UserPreferences.saveUserData(
          token: token,
          idNguoidung: idNguoidung,
          userName: userName,
          phone: phone,
          address: address,
          email: email,
        );

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("✅ Chào mừng $userName!"),
        //     backgroundColor: Colors.black,
        //   ),
        // );

        // 🔥 Chuyển về `MainScreen`
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialIndex: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Đăng nhập thất bại: ${response['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Lỗi kết nối API: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            Image.asset("assets/images/logo.png", height: 55),
            const SizedBox(width: 15, height: 10),
            //const Text("MySD", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
          ],
          
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Iris Couture | Đăng Nhập Tài Khoản",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(height: 30),

              const Text("Xin chào", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Đăng nhập với email và mật khẩu của bạn",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 20),

              _buildTextField("Email*", _emailController, false),
              const SizedBox(height: 20),
              _buildTextField("Mật khẩu*", _passwordController, true),

              _buildRememberForgotRow(),

              const SizedBox(height: 20),

              // 🔹 Nút Đăng nhập
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Đăng nhập", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Tạo tài khoản
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Căn giữa hàng
                  children: [
                    const Text("Bạn không có tài khoản?", style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                      },
                      child: const Text("Tạo tài khoản", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 **Ô nhập liệu**
  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  /// 📌 **Remember Me & Forgot Password**
  Widget _buildRememberForgotRow() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (bool? value) => setState(() => _rememberMe = value!),
        ),
        const Text("Ghi nhớ đăng nhập", style: TextStyle(fontSize: 14)),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPasswordPage())),
          child: const Text("Quên mật khẩu?",
              style: TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}