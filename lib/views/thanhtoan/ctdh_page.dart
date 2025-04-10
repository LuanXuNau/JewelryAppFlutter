import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_trangsuc_vs2/core/config/api_config.dart';
import 'package:ui_trangsuc_vs2/core/services/Cart_service.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import 'package:ui_trangsuc_vs2/core/services/order_service.dart';
import 'package:ui_trangsuc_vs2/views/thanhtoan/order_thanh_cong.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';
import 'package:ui_trangsuc_vs2/views/thanhtoan/paypal_webview.dart';
import 'package:ui_trangsuc_vs2/core/services/paypal_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalPrice;

  const CheckoutPage({
    super.key,
    required this.selectedItems,
    required this.totalPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _tenNguoiNhan = "";
  String _diaChiNhan = "";
  String _soDienThoai = '';
  Set<String> expandedDetails = {};
  String? _selectedPaymentMethod;
  final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await UserPreferences.getUserData();
    setState(() {
      _tenNguoiNhan = userData["userName"] ?? "Chưa rõ";
      _diaChiNhan = userData["address"] ?? "Chưa có địa chỉ";
      _soDienThoai = userData["phone"] ?? "Không có SĐT";
    });
  }

  void _editReceiverInfo() {
    final tenController = TextEditingController(text: _tenNguoiNhan);
    final diaChiController = TextEditingController(text: _diaChiNhan);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa thông tin nhận hàng"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tenController, decoration: const InputDecoration(labelText: "Tên người nhận")),
            TextField(controller: diaChiController, decoration: const InputDecoration(labelText: "Địa chỉ nhận")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tenNguoiNhan = tenController.text;
                _diaChiNhan = diaChiController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  List<String> _getImageUrls(Map<String, dynamic> product) {
    final urls = <String>[];
    for (var key in ['hinhAnh', 'hinh_anh1', 'hinh_anh2']) {
      final img = product[key];
      if (img != null && img.toString().isNotEmpty) {
        urls.add(img.toString().startsWith('http')
            ? img
            : '${APIConfig.baseUrl.replaceAll("/api", "")}/images/$img');
      }
    }
    return urls;
  }

  Widget _buildPriceLine(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text((label == "Giảm giá" ? "- " : "") + currency.format(amount), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildGiftSection(String title, String subtitle, {bool hasCheckbox = false}) {
    return ListTile(
      leading: Image.asset("assets/images/quatang.jpg", width: 40, height: 40),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: hasCheckbox ? const Icon(Icons.check_circle_outline) : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    double tongTienSanPham = widget.totalPrice * 100000;
    double tongTienGiamGia = tongTienSanPham * 0.1;
    double tongTienThanhToan = tongTienSanPham - tongTienGiamGia;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đơn hàng", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Người nhận: $_tenNguoiNhan", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Địa chỉ: $_diaChiNhan"),
                    Text("SĐT: $_soDienThoai"),
                  ],
                ),
                IconButton(onPressed: _editReceiverInfo, icon: const Icon(Icons.more_vert)),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text("${widget.selectedItems.length} sản phẩm", style: const TextStyle(color: Colors.black54)),
                ),
                ...widget.selectedItems.map((product) {
                  final imageUrls = _getImageUrls(product);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrls.isNotEmpty ? imageUrls[0] : '',
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
                              Text(product["idSanpham"] ?? "", style: const TextStyle(fontSize: 13)),
                              Text(product["ten"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    String id = product["idSanpham"];
                                    if (expandedDetails.contains(id)) {
                                      expandedDetails.remove(id);
                                    } else {
                                      expandedDetails.add(id);
                                    }
                                  });
                                },
                                child: const Text("Chi tiết", style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
                              ),
                              if (expandedDetails.contains(product["idSanpham"]))
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text("Chất liệu: ${product["chatlieu"] ?? "Không rõ"}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Số lượng: ${product["soLuong"]}"),
                                  Text(currency.format((product["gia"] ?? 0) * 100000)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(thickness: 1),
                _buildPriceLine("Thành tiền", tongTienSanPham),
                _buildPriceLine("Giảm giá", tongTienGiamGia),
                _buildPriceLine("Tổng tiền", tongTienThanhToan, bold: true),
                const SizedBox(height: 16),
                _buildGiftSection("Bao bì", "Lấy cảm hứng từ di sản của chúng tôi"),
                _buildGiftSection("Tin nhắn quà tặng", "Thêm một ghi chú cá nhân"),
                _buildGiftSection("Thêm túi mua sắm", "", hasCheckbox: true),
                const Divider(thickness: 8),

                ExpansionTile(
                  title: const Text("Phương thức thanh toán"),
                  childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
                  children: [
                    RadioListTile<String>(
                      title: const Text("Tiền mặt"),
                      value: 'cod',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text("Thanh toán bằng Paypal"),
                      value: 'paypal',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                    ),
                  ],
                ),

                _buildInfoTile("Vận chuyển & Giao hàng", "Giao hàng tiết kiệm miễn phí"),
                _buildInfoTile("Trả hàng & Đổi hàng", "Miễn phí"),
                _buildInfoTile("Nhận hàng tại cửa hàng vào ngày hôm sau", ""),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedPaymentMethod == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn phương thức thanh toán!")),
                    );
                    return;
                  }

                  final userData = await UserPreferences.getUserData();
                  final token = userData["token"];

                  if (token == null || token.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bạn chưa đăng nhập!")),
                    );
                    return;
                  }

                  final orderRequest = {
                    "tenNguoiNhan": _tenNguoiNhan,
                    "diaChiNhan": _diaChiNhan,
                    "soDienThoai": _soDienThoai,
                    "tongTienSanPham": tongTienSanPham,
                    "tongTienGiamGia": tongTienGiamGia,
                    "tongTienThanhToan": tongTienThanhToan,
                    "chiTietDonhangs": widget.selectedItems.map((item) {
                      return {
                        "idSanpham": item["idSanpham"],
                        "soLuong": item["soLuong"],
                        "gia": (item["gia"] ?? 0) * 100000,
                      };
                    }).toList(),
                  };

                  final response = await OrderService().createOrder(token, orderRequest);
                  if (response["success"] == true && response["order"] != null) {
                    final String orderId = response["order"]["idDonhang"];

                    if (_selectedPaymentMethod == 'paypal') {
                      final paypalUrl = await PayPalService().createPayPalLink(orderId);
                      if (paypalUrl != null) {
                        for (var item in widget.selectedItems) {
                          await CartService().removeFromCart(item["idSanpham"]);
                        }
                        Navigator.pushReplacement(context, RotationRoute(page: PaypalWebViewPage(paypalUrl: paypalUrl)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Không nhận được link thanh toán PayPal!")));
                      }
                    } else {
                      for (var item in widget.selectedItems) {
                        await CartService().removeFromCart(item["idSanpham"]);
                      }
                      Navigator.pushReplacement(context, RotationRoute(page: OrderSuccessPage(order: response["order"])));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Lỗi: ${response['message'] ?? 'Không xác định'}")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Tiến hành thanh toán",
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}