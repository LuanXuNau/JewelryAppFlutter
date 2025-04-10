import 'dart:ui';

import 'package:ui_trangsuc_vs2/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/main.dart'; // Import MainScreen để giữ Navigation
import 'package:ui_trangsuc_vs2/views/auth/login_page.dart';
import 'package:ui_trangsuc_vs2/views/auth/register_page.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart'; // ✅ Import để sử dụng hiệu ứng chuyển trang

class MyLVPage extends StatelessWidget {
  const MyLVPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📌 Background màu đen (bỏ ảnh nền để test)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/mylv.jpg"), // Kiểm tra lại đường dẫn ảnh
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3), // Nền đen mờ
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // 👈 độ mờ
              child: Container(color: Colors.black.withOpacity(0.1)), // lớp trong suốt để áp filter
            ),
          ),

          // 📌 Nội dung chính với SingleChildScrollView
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 200),

                // 🏆 Logo LV
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                  ),
                ),

                // 🔹 Tiêu đề
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Đăng ký hoặc đăng nhập vào tài khoản của bạn để truy cập nội dung độc quyền.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔳 Nút "Log In"
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        RotationRoute(page: const LoginPage()), // ✅ Dùng hiệu ứng chuyển trang
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 🔲 Nút "Sign Up"
                SizedBox(
                  width: 300,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        RotationRoute(page: const RegisterPage()), // ✅ Dùng hiệu ứng chuyển trang
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Colors.white, width: 1.5),
                    ),
                    child: const Text(
                      "Đăng ký",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔗 "Continue as a Guest"
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      RotationRoute(page: const MainScreen()), // ✅ Dùng hiệu ứng chuyển trang
                    );
                  },
                  child: const Text(
                    "Tiếp tục dưới dạng khách",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
