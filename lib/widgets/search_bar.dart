import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui_trangsuc_vs2/core/services/product_service.dart';
import 'package:ui_trangsuc_vs2/product/product_detail.dart';
import 'package:ui_trangsuc_vs2/core/config/api_config.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  _AnimatedSearchBarState createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isProcessingImage = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String keyword) async {
    if (keyword.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await _productService.searchProducts(keyword);
      if (response['success']) {
        setState(() {
          _searchResults = response['data'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm sản phẩm: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _pickAndSearchImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      String fileName = pickedFile.name.toLowerCase().trim();
      String baseName = fileName.split('.').first.replaceAll(RegExp(r'[^a-z0-9]'), '');

      setState(() => _isProcessingImage = true);

      final products = await _productService.getAllProducts(1, 100);

      for (var p in products) {
        final rawImage = (p["hinhAnh"] ?? "").toString().toLowerCase().trim();
        final productImage = rawImage.contains("/")
            ? rawImage.split("/").last.split("?").first
            : rawImage;
        final productBase = productImage.split('.').first.replaceAll(RegExp(r'[^a-z0-9]'), '');

        debugPrint("\uD83D\uDD0D So sánh: Người dùng = [$baseName] vs Sản phẩm = [$productBase]");

        if (productBase == baseName) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductPage(product: p)),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy sản phẩm phù hợp!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tìm bằng file ảnh: $e")),
      );
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  Widget _buildSearchSuggestions() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: _searchResults.map((product) {
          final hasImage = product['hinhAnh'] != null && product['hinhAnh'].toString().isNotEmpty;
          final imageUrl = hasImage
              ? "${APIConfig.baseUrl}/images/${product['hinhAnh']}"
              : "https://via.placeholder.com/150";

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/sp_1.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            title: Text(
              product['ten'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "${(product['gia'] * 100000).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND",
              style: const TextStyle(color: Colors.white54),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductPage(product: product),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: -0.4,
      child: Column(
        children: [
          if (_searchResults.isNotEmpty) _buildSearchSuggestions(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.black,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white70, width: 1.5),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search, color: Colors.white70),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white70),
                      decoration: const InputDecoration(
                        hintText: "Tìm kiếm sản phẩm...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: _searchProducts,
                    ),
                  ),
                  if (_isProcessingImage)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white70),
                      onPressed: _pickAndSearchImage,
                    ),
                ],
              ),
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
