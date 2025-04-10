import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/core/services/Cart_service.dart';
import 'package:ui_trangsuc_vs2/core/services/wishlist_service.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isWishlisted = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initWishlist();
  }

  Future<void> _initWishlist() async {
    prefs = await SharedPreferences.getInstance();
    Set<String> wishlist = prefs.getStringList('wishlist')?.toSet() ?? {};
    setState(() {
      isWishlisted = wishlist.contains(widget.product['idSanpham']);
    });
  }

  Future<void> _toggleWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> wishlist = prefs.getStringList('wishlist')?.toSet() ?? {};

    if (isWishlisted) {
      await WishlistService().removeFromWishlist(widget.product['idSanpham']);
      wishlist.remove(widget.product['idSanpham']);
    } else {
      await WishlistService().addToWishlist(widget.product['idSanpham']);
      wishlist.add(widget.product['idSanpham']);
    }

    await prefs.setStringList('wishlist', wishlist.toList());

    setState(() {
      isWishlisted = !isWishlisted;
    });
  }

  Future<void> _addToCart() async {
    Map<String, String> userData = await UserPreferences.getUserData();
    String token = userData["token"] ?? "";
    String userId = userData["idNguoidung"] ?? "";

    if (token.isEmpty || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để thêm vào giỏ hàng!")),
      );
      return;
    }

    String? productId = widget.product['idSanpham'];
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: ID sản phẩm không hợp lệ!")),
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
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi hệ thống, vui lòng thử lại sau!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String image = widget.product['hinhAnh'] ?? 'assets/images/sp_1.jpg';
    final String name = widget.product['ten'] ?? 'Sản phẩm';
    final String price = widget.product['gia'] != null
        ? NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format((widget.product['gia'] as num) * 100000)
        : 'Liên hệ';

    return GestureDetector(
      onTap: widget.onTap,
      child: IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/logo.png',
                        image: image,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, __, ___) {
                          return Image.asset('assets/images/sp_1.jpg', fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleWishlist,
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            price,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: _addToCart,
                          child: const Icon(Icons.shopping_cart, color: Colors.black, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
