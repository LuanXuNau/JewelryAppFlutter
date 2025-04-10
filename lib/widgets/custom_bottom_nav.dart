import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Tăng chiều cao để ảnh có không gian di chuyển
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      color: Colors.black,
      child: Column(
        children: [
          // Hàng chữ (có thể nhấn được)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, "Trang Chủ", "assets/images/lv_1.png"),
              _buildNavItem(1, "Cửa Hàng", "assets/images/lv_2.png"),
              _buildNavItem(2, "Tài Khoản", "assets/images/lv_1.png"),
              _buildNavItem(3, "Giỏ Hàng", "assets/images/lv_2.png"),
            ],
          ),
        ],
      ),
    );
  }

  // Widget chung cho từng tab, bọc GestureDetector để nhận click
  Widget _buildNavItem(int index, String label, String imagePath) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        onItemTapped(index);
      },
      behavior: HitTestBehavior.opaque, // Đảm bảo vùng click rộng hơn
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, // Chữ luôn màu trắng
              fontSize: 14,
              
            ),
          ),
          const SizedBox(height: 3), // Khoảng cách giữa chữ và ảnh

          // Ảnh có hiệu ứng chạy từ dưới lên
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, isSelected ? 0 : 30, 0),
            child: isSelected
                ? Image.asset(
                    imagePath,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(width: 20, height: 20), // Giữ chỗ để tránh layout nhảy
          ),
        ],
      ),
    );
  }
  
}
