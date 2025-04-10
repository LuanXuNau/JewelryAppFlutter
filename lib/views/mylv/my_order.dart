import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_trangsuc_vs2/core/services/order_service.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import 'package:ui_trangsuc_vs2/core/config/api_config.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List orders = [];
  List<bool> _isExpanded = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userData = await UserPreferences.getUserData();
    print("🔐 Token hiện tại: ${userData["token"]}");
    final token = userData["token"] ?? "";
    final response = await OrderService().getOrders(token);

    if (response["success"]) {
      setState(() {
        orders = response["orders"];
        _isExpanded = List<bool>.filled(orders.length, false);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: ${response['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Chưa có đơn hàng nào"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final items = order["chitietDonhangs"] ?? [];
                    final firstProduct = items.isNotEmpty ? items[0]["sanpham"] : null;
                    final firstQty = items.isNotEmpty ? items[0]["soluong"] : 0;
                    final firstPrice = items.isNotEmpty ? items[0]["gia"] : 0;

                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Đơn hàng: ${order["idDonhang"]}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 10),
                            if (firstProduct != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      firstProduct["hinhAnh"] != null
                                          ? "${APIConfig.baseUrl}/images/${firstProduct["hinhAnh"]}"
                                          : "",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/lv_cart.jpg", width: 80, height: 80),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(firstProduct["ten"] ?? "Không rõ", style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        //Text("Thương hiệu: ${firstProduct["thuonghieu"] ?? "Không rõ"}"),
                                        Text("Chất liệu: ${firstProduct["chatlieu"] ?? "Không rõ"}"),
                                        Text("Số lượng: $firstQty"),
                                        Text("Giá: ${currency.format(firstPrice * 100000)}"),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (_isExpanded[index] && items.length > 1)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(items.length - 1, (i) {
                                  final sp = items[i + 1]["sanpham"];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          sp["hinhAnh"] != null
                                              ? "${APIConfig.baseUrl}/images/${sp["hinhAnh"]}"
                                              : "",
                                          width: 60,
                                          height: 60,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Image.asset("assets/images/lv_cart.jpg", width: 60, height: 60),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(sp["ten"] ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
                                              Text("SL: ${items[i + 1]["soluong"]} - Giá: ${currency.format(items[i + 1]["gia"] * 100000)}"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tổng tiền: ${currency.format(order["tongTienThanhToan"] * 100000)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                Text(order["trangthai"] ?? "", style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                            if (items.length > 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded[index] = !_isExpanded[index];
                                    });
                                  },
                                  child: Text(_isExpanded[index] ? "Ẩn bớt" : "Xem thêm", style: const TextStyle(color: Colors.black)),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
