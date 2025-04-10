import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/widgets/custom_bottom_nav.dart';
import 'package:ui_trangsuc_vs2/widgets/search_bar.dart';
import 'package:ui_trangsuc_vs2/widgets/product_card.dart';
import 'package:ui_trangsuc_vs2/main.dart';
import 'package:ui_trangsuc_vs2/product/product_detail.dart';
import 'package:ui_trangsuc_vs2/core/services/product_service.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';

class ProductListPage extends StatefulWidget {
  final String? brandId;
  final String? categoryId;
  final String title;

  const ProductListPage({super.key, this.brandId, this.categoryId, required this.title});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _selectedIndex = 1;
  final ProductService _productService = ProductService();
  List<dynamic> _products = [];
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  String? _selectedCategory;
  String? _selectedBrand;
  bool _showFilterDropdown = false;
  String? _expandedMaterial;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newProducts = await _productService.getAllProducts(_currentPage, _pageSize);
      final filteredProducts = newProducts.where((product) {
        final matchesBrand = _selectedBrand == null || product['idThuonghieu'] == _selectedBrand;
        final matchesCategory = _selectedCategory == null || product['idLoai'] == _selectedCategory;
        return matchesBrand && matchesCategory;
      }).toList();

      setState(() {
        _products.addAll(filteredProducts);
        _hasMore = filteredProducts.length == _pageSize;
        _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải sản phẩm: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _fetchProducts();
    }
  }

  void _onNavItemTapped(int index) {
  if (index == _selectedIndex) return;
  Navigator.pushReplacement(
    context,
    RotationRoute(page: MainScreen(initialIndex: index)),
  );
}


  void _applyFilter(String? material, String? brand) {
    setState(() {
      _products.clear();
      _currentPage = 1;
      _hasMore = true;
      _selectedCategory = material;
      _selectedBrand = brand;
      _fetchProducts();
    });
  }

  Widget _buildFilterDropdown() {
    return Positioned(
      top: kToolbarHeight + 10,
      right: 10,
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text("Tất cả sản phẩm"),
                onTap: () {
                  _applyFilter(null, null);
                  setState(() => _showFilterDropdown = false);
                },
              ),
              _buildMaterialGroup("Trang sức Bạc", "L01"),
              _buildMaterialGroup("Trang sức Vàng", "L02"),
              _buildMaterialGroup("Trang sức Kim Cương", "L03"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialGroup(String title, String materialId) {
    final isExpanded = _expandedMaterial == materialId;
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        setState(() => _expandedMaterial = expanded ? materialId : null);
      },
      children: [
        ListTile(
          title: const Text("Vòng tay và nhẫn"),
          onTap: () => _applyFilter(materialId, "TH01"),
        ),
        ListTile(
          title: const Text("Dây chuyền"),
          onTap: () => _applyFilter(materialId, "TH02"),
        ),
        ListTile(
          title: const Text("Bông tai"),
          onTap: () => _applyFilter(materialId, "TH03"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.title == "Tất cả sản phẩm")
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: () => setState(() => _showFilterDropdown = !_showFilterDropdown),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: _products.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = _products[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    RotationRoute(page: ProductPage(product: product)),
                                  );
                                },

                              );
                            },
                            childCount: _products.length,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
          ),
          const AnimatedSearchBar(),
          if (_showFilterDropdown) _buildFilterDropdown(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavItemTapped,
      ),
    );
  }
}