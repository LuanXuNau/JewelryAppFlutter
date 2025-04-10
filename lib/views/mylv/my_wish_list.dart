import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/core/services/wishlist_service.dart';
import 'package:ui_trangsuc_vs2/widgets/product_wish.dart';
import 'package:ui_trangsuc_vs2/product/product_detail.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlist = [];
  bool _isLoading = true;

  String? selectedLoai;
  String? selectedThuongHieu;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localWishlist = prefs.getStringList('wishlist');

    final response = await WishlistService().fetchWishlist();

    if (response['success'] && response['data'] != null) {
      List<Map<String, dynamic>> apiWishlist =
          List<Map<String, dynamic>>.from(response['data']);

      if (localWishlist != null) {
        for (String productId in localWishlist) {
          bool existsInAPI =
              apiWishlist.any((item) => item['idSanpham'] == productId);
          if (!existsInAPI) {
            var product =
                await WishlistService().fetchProductById(productId);
            if (product != null) {
              apiWishlist.add(product);
            }
          }
        }
      }

      setState(() {
        wishlist = apiWishlist;
        _isLoading = false;
      });

      List<String> updatedWishlist =
          apiWishlist.map((item) => item['idSanpham'].toString()).toList();
      await prefs.setStringList('wishlist', updatedWishlist);
    } else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                response['message'] ?? 'Không thể lấy danh sách yêu thích!')),
      );
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    final response = await WishlistService().removeFromWishlist(productId);
    if (response['success']) {
      setState(() {
        wishlist.removeWhere((item) => item['idSanpham'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                response['message'] ?? 'Đã xóa khỏi danh sách yêu thích!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                response['message'] ?? 'Không thể xóa khỏi danh sách yêu thích!')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredWishlist {
    return wishlist.where((item) {
      final matchLoai =
          selectedLoai == null || item['idLoai'] == selectedLoai;
      final matchThuongHieu = selectedThuongHieu == null ||
          item['idThuonghieu'] == selectedThuongHieu;
      return matchLoai && matchThuongHieu;
    }).toList();
  }

  Widget _buildFilterChip(String label, String? loai, String? thuongHieu) {
    final isSelected =
        selectedLoai == loai && selectedThuongHieu == thuongHieu;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.black,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        onSelected: (_) {
          setState(() {
            selectedLoai = loai;
            selectedThuongHieu = thuongHieu;
          });
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return const Center(
      child: Text(
        "Danh sách yêu thích trống!",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Danh sách yêu thích",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlist.isEmpty
              ? _buildEmptyWishlist()
              : Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          _buildFilterChip("Tất cả", null, null),
                          _buildFilterChip("Bạc", "L01", null),
                          _buildFilterChip("Vàng", "L02", null),
                          _buildFilterChip("Kim cương", "L03", null),
                          _buildFilterChip("Vòng tay & nhẫn", null, "TH01"),
                          _buildFilterChip("Dây chuyền", null, "TH02"),
                          _buildFilterChip("Bông tai", null, "TH03"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredWishlist.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredWishlist[index];

                          final fixedProduct = {
                            ...product,
                            "hinhAnh": product["hinhAnh"] ?? "",
                            "hinh_anh1":
                                product["hinh_anh1"] ?? product["hinhAnh1"] ?? "",
                            "hinh_anh2":
                                product["hinh_anh2"] ?? product["hinhAnh2"] ?? "",
                          };

                          return ProductWish(
                            product: fixedProduct,
                            onRemove: () => _removeFromWishlist(
                                product['idSanpham']),
                            onTap: () {
                              print("🧩 === CLICK SẢN PHẨM YÊU THÍCH ===");
                              print("🖼️ hinhAnh: ${fixedProduct["hinhAnh"]}");
                              print("🖼️ hinh_anh1: ${fixedProduct["hinh_anh1"]}");
                              print("🖼️ hinh_anh2: ${fixedProduct["hinh_anh2"]}");
                              print("🆔 ID: ${fixedProduct["idSanpham"]}");
                              print("📦 Tên: ${fixedProduct["ten"]}");
                              print("💰 Giá: ${fixedProduct["gia"]}");
                              print("📄 FULL JSON: $fixedProduct");

                              Navigator.push(
                                context,
                                RotationRoute(
                                  page: ProductPage(product: fixedProduct),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
