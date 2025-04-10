import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/views/mylv/my_order.dart';
import 'package:ui_trangsuc_vs2/widgets/custom_bottom_nav.dart';
import 'package:ui_trangsuc_vs2/views/mylv/my_info_page.dart';
import 'package:ui_trangsuc_vs2/views/mylv/my_wish_list.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';

class MyProfilePage extends StatefulWidget {
  final String userName;
  final String phone;
  final String address;
  final String email;

  const MyProfilePage({
    super.key,
    required this.userName,
    required this.phone,
    required this.address,
    required this.email,
  });

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  int _selectedIndex = 2; // Mặc định tab MyLV được chọn

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // TODO: Thêm logic chuyển trang nếu cần
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Bỏ icon back
        title: Text(
          "Chào mừng ${widget.userName}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          _buildProfileItem(Icons.person_outline, "Cá nhân", () {
            Navigator.push(
              context,
              RotationRoute(
                page: MyInfoPage(
                  name: widget.userName, // 🔥 Truyền dữ liệu từ MyProfilePage
                  phone: widget.phone,
                  address: widget.address,
                  email: widget.email,
                ),
              ),
            );
          }),
          _buildProfileItem(Icons.location_on_outlined, "Thêm địa chỉ", () {}),
          _buildProfileItem(Icons.notifications_outlined, "Thông báo", () {}),
          _buildProfileItem(Icons.calendar_today_outlined, "Lịch hẹn", () {}),
          _buildProfileItem(Icons.cleaning_services_outlined, "Dịch vụ chăm sóc", () {}),
          _buildProfileItem(Icons.shopping_bag_outlined, "Đơn hàng", () {
            Navigator.push(
              context,
              RotationRoute(page: const OrderHistoryPage()),
            );

          }),
          _buildProfileItem(Icons.verified_outlined, "Chứng chỉ", () {}),
          _buildProfileItem(Icons.favorite, "Danh sách yêu thích", () {
            Navigator.push(
              context,
              RotationRoute(page: const WishlistPage()),
            );

          }),
          _buildProfileItem(Icons.star_border, "Biểu tượng", () {}),
          _buildProfileItem(Icons.connect_without_contact_outlined, "Kết nối", () {}),
        ],
      ),
    );
  }

  /// 🛠 **Widget danh sách profile item**
  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 28, color: Colors.black),
          title: Text(title, style: const TextStyle(fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
          onTap: onTap,
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}