
import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/views/home/mylv_page.dart';
import 'package:ui_trangsuc_vs2/main.dart';

class TestNavigation extends StatelessWidget implements PreferredSizeWidget {

  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black, // Màu nền của thanh navigation
      title: Text(
        "Bạn chưa có tài khoản!!!!",
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 2)),
                  );

 // Điều hướng về trang Login
          },
          child: Text(
            "Đăng nhập",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Colors.white, // Nút màu trắng
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(width: 10), // Khoảng cách giữa nút và mép phải
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
