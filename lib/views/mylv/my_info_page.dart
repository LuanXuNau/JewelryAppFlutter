import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import 'package:ui_trangsuc_vs2/views/auth/forget_pass.dart';
import 'package:ui_trangsuc_vs2/views/home/mylv_page.dart';
import 'package:ui_trangsuc_vs2/main.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart'; // ✅ Import để sử dụng hiệu ứng chuyển trang

class MyInfoPage extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String email;

  const MyInfoPage({
    super.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

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
        title: const Text("Cá nhân",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 🔹 My Profile Section
            _buildSectionTitle("Thông tin cá nhân"),
            _buildInfoBox([
              _buildInfoRow("Tên", name),
              _buildInfoRow("Số điện thoại", phone),
              _buildInfoRow("Địa chỉ", address),
            ]),

            const SizedBox(height: 20),

            // 🔹 Login Information Section
            _buildSectionTitle("Thông tin đăng nhập"),
            _buildInfoBox([
              _buildInfoRow("Email", email),
              _buildPasswordRow(context), // Cập nhật để truyền context
            ]),

            const Spacer(),

            // 🔥 Logout
            Center(
              child: TextButton(
                onPressed: () async {
                  // 🔥 Xóa thông tin người dùng khỏi SharedPreferences
                  await UserPreferences.clearUserData(); // Xóa tất cả thông tin người dùng

                  // Sau khi đăng xuất, quay lại trang MainScreen và xóa tất cả các màn hình trước đó
                  Navigator.pushAndRemoveUntil(
                    context,
                    RotationRoute(page: const MainScreen(initialIndex: 2)),
                    (route) => false, // Xóa toàn bộ stack
                  );
                },
                child: const Text(
                  "Đăng xuất",
                  style: TextStyle(fontSize: 16, color: Colors.black, decoration: TextDecoration.underline),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 📌 **Hàm tạo tiêu đề của từng section**
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 📌 **Hàm tạo hộp chứa thông tin**
  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 📌 **Hàm tạo từng dòng thông tin**
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// 📌 **Hàm tạo dòng thông tin mật khẩu với Icon bút chì**
  Widget _buildPasswordRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Password", style: TextStyle(fontSize: 16, color: Colors.black54)),
          Row(
            children: [
              const Text("******", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // 🔥 Chuyển đến trang Forget Password khi bấm vào icon bút chì
                  Navigator.push(
                  context,
                  RotationRoute(page: const ResetPasswordPage()),
                );

                },
                child: const Icon(Icons.edit, size: 18, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
