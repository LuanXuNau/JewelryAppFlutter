import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/product/product_list.dart';
import 'package:ui_trangsuc_vs2/widgets/search_bar.dart';
import 'package:ui_trangsuc_vs2/views/shop/store_local.dart';
import 'package:ui_trangsuc_vs2/widgets/tranision.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> _banners = [
    {
      "image": "assets/images/lv_banner_3.jpg",
      "text": "Tất cả sản phẩm",
      "type": "all",
    },
    {
      "image": "assets/images/lv_banner_1.jpg",
      "text": "Sản phẩm Dior",
      "type": "brand",
      "id": "TH01",
    },
    {
      "image": "assets/images/lv_banner_4.jpg",
      "text": "Kim cương",
      "type": "category",
      "id": "L01",
    },
    {
      "image": "assets/images/lv_banner_2.jpg",
      "text": "Đá quý",
      "type": "category",
      "id": "L02",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _banners.length) {
          _pageController.jumpToPage(0); // chuyển thẳng về đầu
          setState(() {
            _currentPage = 0;
          });
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentPage = nextPage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Cửa hàng",
          style: TextStyle(fontSize: 22, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// 🎠 Banner
                SizedBox(
                  height: 390,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _banners.length,
                        itemBuilder: (context, index) {
                          final banner = _banners[index];
                          return GestureDetector(
                            onTap: () => _onBannerTapped(banner),
                            child: Stack(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  child: Image.asset(
                                    banner["image"],
                                    key: ValueKey(banner["image"]),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        banner["text"],
                                        style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 15),
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                      Positioned(
                        bottom: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _banners.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 10 : 6,
                              height: _currentPage == index ? 10 : 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? Colors.white : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                /// Danh mục
                Column(
                  children: [
                    _buildCategoryTile("Vòng tay và nhẫn", "TH01", true),
                    _buildCategoryTile("Dây chuyền", "TH02", true),
                    _buildCategoryTile("Bông tai", "TH03", true),
                    _buildCategoryTile("Trang sức Bạc", "L01", false),
                    _buildCategoryTile("Trang sức Vàng", "L02", false),
                    _buildCategoryTile("Trang sức Kim Cương", "L03", false),
                    Image.asset(
                      "assets/images/ic_store.jpg",
                      width: double.infinity,
                      height: 500,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Text(
                            "Cửa hàng Iris Couture",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Tìm cửa hàng gần với bạn nhất và trải nghiệm sản phẩm chất lượng cao.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Tìm cửa hàng gần bạn", style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 150),
                  ],
                ),
              ],
            ),
          ),
          const AnimatedSearchBar(),
        ],
      ),
    );
  }

  void _onBannerTapped(Map<String, dynamic> banner) {
  if (banner["type"] == "all") {
    Navigator.push(context, RotationRoute(
      page: ProductListPage(title: banner["text"]),
    ));
  } else if (banner["type"] == "brand") {
    Navigator.push(context, RotationRoute(
      page: ProductListPage(title: banner["text"], brandId: banner["id"]),
    ));
  } else if (banner["type"] == "category") {
    Navigator.push(context, RotationRoute(
      page: ProductListPage(title: banner["text"], categoryId: banner["id"]),
    ));
  }
}

  Widget _buildCategoryTile(String title, String id, bool isBrand) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
            context,
            RotationRoute(
              page: ProductListPage(
                title: title,
                brandId: isBrand ? id : null,
                categoryId: isBrand ? null : id,
              ),
            ),
          );
          },
        ),
        const Divider(),
      ],
    );
  }
}
