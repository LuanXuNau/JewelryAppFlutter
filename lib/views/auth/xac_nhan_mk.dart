import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/views/auth/login_page.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

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
            Navigator.pop(context); // Quay lại Reset Password Page
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/lv_logo.png", // Logo LV
              height: 50,
            ),
            const SizedBox(width: 8),
            const Text(
              "MyIC",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),

            // 🔹 Tiêu đề chính
            const Text(
              "Kiểm tra email của bạn",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Liên kết để đặt lại mật khẩu đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư đến.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // 🔹 Nút "Go to Login"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Đi đến Đăng nhập", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Hộp thông tin về MyLV
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "NHỮNG GÌ BẠN SẼ TÌM THẤY TRONG TÀI KHOẢN MYLV CỦA MÌNH",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  _infoRow(Icons.shopping_bag_outlined, "Theo dõi đơn hàng, việc sửa chữa và truy cập hóa đơn của bạn."),
                  _divider(),

                  _infoRow(Icons.person_outline, "Quản lý thông tin cá nhân của bạn."),
                  _divider(),

                  _infoRow(Icons.email_outlined, "Nhận email từ Iris Couture."),
                  _divider(),

                  _infoRow(Icons.favorite_border, "Tạo danh sách mong muốn, duyệt giao diện và chia sẻ."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget hiển thị hàng thông tin
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  // 🔹 Divider giúp UI gọn gàng hơn
  Widget _divider() {
    return Divider(
      color: Colors.grey.shade300, 
      thickness: 1,
      height: 20,
    );
  }
}
