import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/views/thanhtoan/ctdh_page.dart';
import 'package:ui_trangsuc_vs2/core/services/product_service.dart';
import 'package:ui_trangsuc_vs2/core/services/Cart_service.dart';
import 'package:ui_trangsuc_vs2/core/services/wishlist_service.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import 'package:ui_trangsuc_vs2/widgets/product_card.dart';
import 'package:intl/intl.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';
import 'package:camera/camera.dart';
import 'package:ui_trangsuc_vs2/widgets/thu_san_pham.dart';
import 'package:ui_trangsuc_vs2/core/config/api_config.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductPage({super.key, required this.product});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();
  List<dynamic> _relatedProducts = [];
  bool isLoved = false;
  int _currentImageIndex = 0;
  late PageController _imagePageController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _fetchRelatedProducts();
    _saveRecentlyViewed();
    _checkIfLoved();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkIfLoved() async {
    final wishlist = await WishlistService().fetchWishlist();
    if (wishlist["success"] == true && wishlist["data"] is List) {
      final productId = widget.product["idSanpham"];
      final exists = (wishlist["data"] as List)
          .any((item) => item["idSanpham"] == productId);
      if (exists) {
        setState(() => isLoved = true);
      }
    }
  }

  

  Future<void> _saveRecentlyViewed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentProducts = prefs.getStringList("recentlyViewed") ?? [];
    String productJson = jsonEncode(widget.product);
    if (!recentProducts.contains(productJson)) {
      recentProducts.insert(0, productJson);
    }
    if (recentProducts.length > 5) {
      recentProducts = recentProducts.sublist(0, 5);
    }
    await prefs.setStringList("recentlyViewed", recentProducts);
  }

  Future<void> _fetchRelatedProducts() async {
    try {
      final allProducts = await _productService.getAllProducts(1, 20);
      setState(() {
        _relatedProducts = allProducts
            .where((p) => p["idSanpham"] != widget.product["idSanpham"])
            .toList();
      });
    } catch (e) {
      print("Lỗi khi lấy danh sách sản phẩm: $e");
    }
  }

  Future<void> _addToWishlist() async {
    String productId = widget.product["idSanpham"] ?? "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để thêm vào danh sách yêu thích!")),
      );
      return;
    }

    final result = await WishlistService().addToWishlist(productId);
    if (result["success"]) {
      setState(() => isLoved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Đã thêm vào danh sách yêu thích!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Thêm vào danh sách yêu thích thất bại!")),
      );
    }
  }

  Future<void> _addToCart() async {
    Map<String, String> userData = await UserPreferences.getUserData();
    String token = userData["token"] ?? "";
    String productId = widget.product["idSanpham"] ?? "";

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để thêm vào giỏ hàng!")),
      );
      return;
    }

    final response = await CartService().addToCart(token, productId, 1);
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product['ten']} đã được thêm vào giỏ hàng!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Không thể thêm vào giỏ hàng!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi hệ thống, vui lòng thử lại sau!")),
      );
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_imagePageController.hasClients && mounted) {
        int nextIndex = (_currentImageIndex + 1) % _imageUrls.length;
        _imagePageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<String> get _imageUrls {
  final urls = <String>[];

  for (var key in ['hinhAnh', 'hinh_anh1', 'hinh_anh2']) {
    final img = widget.product[key];
    if (img != null && img.toString().isNotEmpty) {
      // ✅ Nếu img đã là URL thì dùng luôn
      if (img.toString().startsWith("http")) {
        urls.add(img);
      } else {
        // ✅ Nếu chỉ là tên file, thì gắn baseUrl/images/
        urls.add('${APIConfig.baseUrl.replaceAll("/api", "")}/images/$img');
      }
    }
  }

  return urls;
}


  @override
  Widget build(BuildContext context) {
    final imageUrls = _imageUrls;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(widget.product["ten"] ?? "Không có tên",
                      style: const TextStyle(fontSize: 22, color: Colors.black)),
                  const SizedBox(height: 6),
                  if (widget.product["idSanpham"] != null)
                    Text(widget.product["idSanpham"],
                        style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Ảnh tràn màn hình
            Stack(
              children: [
                SizedBox(
                  height: 500,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _imagePageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _imagePageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_imagePageController.position.haveDimensions) {
                            value = _imagePageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                          }
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(scale: value, child: child),
                          );
                        },
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset("assets/images/logo.png"),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isLoved ? Icons.favorite : Icons.favorite_border,
                      color: isLoved ? Colors.red : Colors.black,
                      size: 28,
                    ),
                    onPressed: _addToWishlist,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: List.generate(imageUrls.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 4,
                          color: index <= _currentImageIndex ? Colors.black : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Giá", style: TextStyle(color: Colors.black, fontSize: 14)),
                      Text(
                        widget.product["gia"] != null
                            ? NumberFormat.currency(locale: 'vi_VN', symbol: 'VND')
                                .format((widget.product["gia"] as int) * 100000)
                            : "Liên hệ để biết giá",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Thử sản phẩm qua camera
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera, color: Colors.black),
                      label: const Text("Thử sản phẩm qua camera", style: TextStyle(fontSize: 16)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TryOnCameraPage(product: widget.product),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Mua ngay
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                  onPressed: () {
                          final product = widget.product;

                          final selectedProduct = {
                            "idSanpham": product["idSanpham"],
                            "ten": product["ten"],
                            "gia": product["gia"],
                            "soLuong": 1,
                            "chatlieu": product["chatlieu"],
                            "kichThuoc": product["kichThuoc"],

                            // ✅ Thêm đủ 5 key để tránh lỗi bên CheckoutPage
                            "hinhAnh": product["hinhAnh"] ?? product["hinh_anh1"] ?? product["hinh_anh2"] ?? "",
                            "hinhAnh1": product["hinhAnh1"] ?? product["hinh_anh1"] ?? "",
                            "hinhAnh2": product["hinhAnh2"] ?? product["hinh_anh2"] ?? "",
                            "hinh_anh1": product["hinh_anh1"] ?? product["hinhAnh1"] ?? "",
                            "hinh_anh2": product["hinh_anh2"] ?? product["hinhAnh2"] ?? "",
                          };


                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                selectedItems: [selectedProduct],
                                totalPrice: (product["gia"] ?? 0).toDouble(),
                              ),
                            ),
                          );
                        },


                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Mua ngay", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _addToCart,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Thêm vào giỏ hàng", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Mô tả
                  const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product["mota"] ?? "Không có mô tả",
                      style: const TextStyle(color: Colors.black54, fontSize: 14)),

                  if (widget.product["chatlieu"] != null) ...[
                    const SizedBox(height: 16),
                    const Text("Chất liệu", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.product["chatlieu"]),
                  ],
                  const SizedBox(height: 40),

                  // Gợi ý sản phẩm
                  const Text("Bạn có thể thích", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 230,
                    child: _relatedProducts.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _relatedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _relatedProducts[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: SizedBox(
                                  width: 160,
                                  child: ProductCard(
                                    product: product,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        RotationRoute( // ✅ Thêm hiệu ứng chuyển trang xoay
                                          page: ProductPage(product: product),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
