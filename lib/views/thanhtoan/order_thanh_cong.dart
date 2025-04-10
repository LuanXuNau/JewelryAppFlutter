import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui_trangsuc_vs2/main.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';

class OrderSuccessPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderSuccessPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final List items = order["chitietDonhangs"] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Đơn hàng của bạn",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ✅ Box thông báo
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Đặt hàng thành công!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Mã đơn hàng: ${order['idDonhang']}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text("Người nhận: ${order['tenNguoiNhan']}"),
                    Text("Địa chỉ: ${order['diaChiNhan']}"),
                    Text("SĐT: ${order['soDienThoai']}")
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ Danh sách sản phẩm
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final sp = item["sanpham"] ?? {};
                  final imageUrl = sp["hinhAnh"] != null
                      ? "http://localhost:5114/images/${sp["hinhAnh"]}"
                      : "assets/images/lv_cart.jpg";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Image.asset("assets/images/lv_cart.jpg", width: 70, height: 70),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sp["ten"] ?? "Không rõ",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("Số lượng: ${item["soluong"]}", style: const TextStyle(fontSize: 14)),
                              Text("Giá: ${currency.format((item["gia"] ?? 0) * 100000)}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// ✅ Tổng tiền
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  _buildPriceLine("Tổng tiền sản phẩm", order["tongTienSanPham"], currency),
                  _buildPriceLine("Giảm giá", order["tongTienGiamGia"], currency, isNegative: true),
                  const Divider(),
                  Shimmer.fromColors(
                    baseColor: Colors.black,
                    highlightColor: Colors.grey.shade300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Thành tiền", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          currency.format((order["tongTienThanhToan"] ?? 0) * 100000),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ✅ Nút quay về trang chủ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    RotationRoute(page: const MainScreen()), // ✅ Áp hiệu ứng xoay khi quay về trang chủ
                    (route) => false,
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  "Quay về trang chủ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceLine(String label, dynamic amount, NumberFormat currency, {bool isNegative = false}) {
    final double value = (amount is num) ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
    final double multipliedValue = value * 100000;
    final text = isNegative ? "-${currency.format(multipliedValue)}" : currency.format(multipliedValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isNegative ? Colors.red : Colors.black,
              fontWeight: isNegative ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
