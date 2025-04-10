import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/core/services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  bool _subscribe = false; // Kiểm tra checkbox
  bool _isLoading = false; // Trạng thái loading khi đăng ký
  final AuthService _authService = AuthService(); // Dịch vụ API

  // Controllers cho dữ liệu nhập
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  /// 🛠 **Xử lý đăng ký**
 Future<void> _handleRegister() async {
  setState(() {
    _isLoading = true;
  });

  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final phone = _phoneController.text.trim();
  final address = _addressController.text.trim();

  // Kiểm tra đơn giản
  if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty || address.isEmpty) {
    _showSnackBar("❌ Vui lòng điền đầy đủ thông tin.");
    setState(() => _isLoading = false);
    return;
  }

  try {
    final response = await _authService.registerUser(name, email, password, phone, address);

    if (response["success"] == true) {
      _showSnackBar("🎉 Đăng ký thành công!", isSuccess: true);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      });
    } else {
      _showSnackBar("❌ ${response["message"] ?? "Đăng ký thất bại!"}");
    }
  } catch (e) {
    _showSnackBar("❌ Lỗi đăng ký: $e");
  }

  setState(() {
    _isLoading = false;
  });
}

void _showSnackBar(String message, {bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
    ),
  );
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo.png", height: 50),
            const SizedBox(width: 8),
            // const Text(
            //   "MyIC",
            //   style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black),
            // ),
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
              const Center(
                child: Text(
                  "Iris Couture | Đăng ký",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Tạo tài khoản",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildTextField("Your Name*", _nameController),
              _buildTextField("Email*", _emailController),
              _buildPasswordField(),
              _buildTextField("Address*", _addressController),
              _buildTextField("Your Phone*", _phoneController),

              const SizedBox(height: 20),

              // ✅ Checkbox Subscribe
              Row(
                children: [
                  Checkbox(
                    value: _subscribe,
                    onChanged: (bool? value) {
                      setState(() {
                        _subscribe = value!;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Đăng ký để nhận email của Iris Couture. Bằng cách đăng ký, bạn đồng ý với Chính sách bảo mật của chúng tôi.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🎯 Nút Continue
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Tiếp tục",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛠 **Hàm tạo TextField**
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder())),
        const SizedBox(height: 20),
      ],
    );
  }

  /// 🛠 **Hàm tạo Password Field**
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password*",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
