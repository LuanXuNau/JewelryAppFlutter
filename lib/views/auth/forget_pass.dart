import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/core/services/auth_service.dart';
import 'package:ui_trangsuc_vs2/views/auth/register_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Khóa form để validate
  final AuthService _authService = AuthService(); // API xử lý xác thực

  bool _isLoading = false; // Trạng thái loading

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  /// ✅ **Gọi API để đặt lại mật khẩu**
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Bắt đầu loading

      String email = _emailController.text.trim();
      String phone = _phoneController.text.trim();
      String newPassword = _newPasswordController.text.trim();

      final response =
          await _authService.resetPassword(email, phone, newPassword);

      setState(() => _isLoading = false); // Dừng loading

      if (response["success"] == true) {
        _showSnackBar("✅ Mật khẩu đã được đặt lại thành công!", Colors.green);

        // Điều hướng người dùng đến trang đăng nhập hoặc trang khác
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(
              context); // Quay lại trang trước (hoặc chuyển hướng khác)
        });
      } else {
        String errorMessage =
            response["message"] ?? "❌ Đặt lại mật khẩu thất bại!";
        _showSnackBar(errorMessage, Colors.red);
      }
    }
  }

  /// ✅ **Hiển thị thông báo lỗi/thành công**
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/logo.png", height: 50),
            const SizedBox(width: 8),
            // const Text("MyIC",
            //     style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.black)),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 🔹 Tiêu đề chính
                const Text("Thay đổi mật khẩu",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  "Nhập email và số điện thoại đã đăng ký để đặt lại mật khẩu.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 20),

                // 🔹 Email Input
                _buildInputField("Email*", _emailController,
                    TextInputType.emailAddress, false),

                // 🔹 Phone Input
                _buildInputField("Phone Number*", _phoneController,
                    TextInputType.phone, false),

                // 🔹 New Password Input
                _buildInputField("New Password*", _newPasswordController,
                    TextInputType.text, true),

                const SizedBox(height: 20),

                // 🔹 Điều hướng đến trang Đăng ký nếu chưa có tài khoản
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Bạn không có tài khoản?",
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Tạo tài khoản",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Nút Đặt lại mật khẩu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword, // Gọi API
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Đặt lại mât khẩu",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📌 **Hàm tạo ô nhập liệu**
  Widget _buildInputField(String label, TextEditingController controller,
      TextInputType inputType, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            hintText: "Nhập thông tin chi tiết của bạn",
            suffixIcon: isPassword
                ? IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () {
                      setState(() {
                        isPassword = !isPassword;
                      });
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label cannot be empty";
            }
            if (label == "Email*") {
              String pattern =
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
              if (!RegExp(pattern).hasMatch(value))
                return "Please enter a valid email address";
            }
            if (label == "Phone Number*") {
              String pattern = r'^\d{10,11}$';
              if (!RegExp(pattern).hasMatch(value))
                return "Please enter a valid phone number";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}