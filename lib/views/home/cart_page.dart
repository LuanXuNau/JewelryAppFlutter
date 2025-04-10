import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/core/services/Cart_service.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ui_trangsuc_vs2/views/thanhtoan/ctdh_page.dart';
import 'package:ui_trangsuc_vs2/core/config/api_config.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0;
  Map<String, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _fetchCart();
    });
  }

  Future<void> _fetchCart() async {
  Map<String, String> userData = await UserPreferences.getUserData();
  String token = userData["token"] ?? "";

  if (token.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng đăng nhập để xem giỏ hàng!")),
    );
    setState(() => _isLoading = false);
    return;
  }

  print("🚀 Gọi API: ${APIConfig.baseUrl}/api/cart");
  final response = await CartService().fetchCart(token);
  print("✅ Phản hồi: ${response['success']}");

  if (response['success'] == true && response['data'] != null) {
    List<dynamic> rawData = response['data'];

    setState(() {
      _cartItems = rawData.map((item) {
        final sanpham = item["sanpham"] ?? {};
        final thuonghieu = sanpham["idThuonghieuNavigation"] ?? {};
        final String rawImage = sanpham["hinhAnh"] ?? "";

        // ✅ Xử lý đường dẫn ảnh
        String hinhAnh = "";
        if (rawImage.contains("localhost")) {
          hinhAnh = rawImage.replaceAll("http://localhost:5114", APIConfig.baseUrl);
        } else if (rawImage.contains("127.0.0.1")) {
          hinhAnh = rawImage.replaceAll("http://127.0.0.1:5114", APIConfig.baseUrl);
        } else if (rawImage.startsWith("http")) {
          hinhAnh = rawImage;
        } else if (rawImage.isNotEmpty) {
          hinhAnh = "${APIConfig.baseUrl}/images/$rawImage";
        }

        print("🖼️ Raw: $rawImage");
        print("👉 Final image: $hinhAnh");

        return {
          "idSanpham": item["idSanpham"] ?? "",
          "soLuong": item["soLuong"] ?? 1,
          "ten": sanpham["ten"] ?? "Không có tên",
          "gia": sanpham["gia"] ?? 0,
          "hinhAnh": hinhAnh.isNotEmpty ? hinhAnh : null,
          "chatlieu": sanpham["chatlieu"] ?? "N/A",
          "thuonghieu": thuonghieu["ten"] ?? "Không rõ",
        };
      }).toList();

      _selectedItems = {
        for (var item in _cartItems) item["idSanpham"]: false
      };
      _isLoading = false;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Không thể lấy giỏ hàng: ${response['message']}')),
    );
    setState(() => _isLoading = false);
  }
}



  void _updateTotalPrice() {
    setState(() {
      _totalPrice = _cartItems
          .where((item) => _selectedItems[item["idSanpham"]] == true)
          .fold(0, (sum, item) => sum + (item["gia"] * item["soLuong"]));
    });
  }

  void _updateQuantity(String productId, int newQuantity) async {
    if (newQuantity < 1) return;

    Map<String, String> userData = await UserPreferences.getUserData();
    String token = userData["token"] ?? "";

    final response = await CartService().updateCart(token, {
      "productId": productId,
      "quantity": newQuantity,
    });

    if (response["success"]) {
      setState(() {
        for (var item in _cartItems) {
          if (item["idSanpham"] == productId) {
            item["soLuong"] = newQuantity;
            break;
          }
        }
      });
      _updateTotalPrice();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể cập nhật: ${response['message']}")),
      );
    }
  }

  Widget _buildCartList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final product = _cartItems[index];
              final isSelected = _selectedItems[product["idSanpham"]] ?? false;

              return Card(
                color: const Color(0xFFFFFFFF), // Trắng tinh
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      /// Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                          color: isSelected ? Colors.black : Colors.transparent,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              _selectedItems[product["idSanpham"]] = !isSelected;
                              _updateTotalPrice();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              isSelected ? Icons.check : Icons.circle_outlined,
                              color: isSelected ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      /// Image with fallback
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product["hinhAnh"] != null && product["hinhAnh"].toString().isNotEmpty
                              ? Image.network(
                                  product["hinhAnh"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset("assets/images/lv_cart.jpg", fit: BoxFit.cover),
                                )
                              : Image.asset("assets/images/lv_cart.jpg", fit: BoxFit.cover),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product["ten"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("Chất liệu: ${product["chatlieu"]}", style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(
                              NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(product["gia"] * product["soLuong"] * 100000),
                              style: const TextStyle(fontSize: 15, color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                      /// Quantity buttons
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _updateQuantity(product["idSanpham"], product["soLuong"] + 1),
                          ),
                          Text("${product['soLuong']}"),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _updateQuantity(product["idSanpham"], product["soLuong"] - 1),
                          ),
                        ],
                      ),

                      /// Delete
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final response = await CartService().removeFromCart(product["idSanpham"]);
                          if (response["success"]) {
                            setState(() {
                              _cartItems.removeAt(index);
                              _selectedItems.remove(product["idSanpham"]);
                              _updateTotalPrice();
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response["message"])),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// Bottom total & order
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(_totalPrice * 100000)}",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  final selectedItems = _cartItems.where((item) => _selectedItems[item["idSanpham"]] == true).toList();
                  if (selectedItems.isNotEmpty) {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => CheckoutPage(
                        selectedItems: selectedItems,
                        totalPrice: _totalPrice,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng chọn sản phẩm để thanh toán")),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("Đặt hàng", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Giỏ hàng", style: TextStyle(fontSize: 22, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/lv_cart.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.black),
                        SizedBox(height: 20),
                        Text(
                          "Không có sản phẩm nào trong giỏ hàng.",
                          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildCartList(),
    );
  }
}
