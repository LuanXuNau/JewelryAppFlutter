import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/product/product_detail.dart';
import 'package:ui_trangsuc_vs2/widgets/search_bar.dart';
import 'package:ui_trangsuc_vs2/core/services/product_service.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onBottomNavVisibilityChanged;

  const HomePage({super.key, required this.onBottomNavVisibilityChanged});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = "Guest";
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;

  int _currentPage = 0;
  late Timer _timer;
  final PageController _bannerController = PageController();
  final PageController _experienceController = PageController();

  List<dynamic> _recentlyViewedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _loadRecentlyViewedProducts();
    _startAutoScroll();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerController.dispose();
    _experienceController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString("userName") ?? "Guest";
    });
  }

  Future<void> _loadRecentlyViewedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentData = prefs.getStringList("recentlyViewed") ?? [];

    setState(() {
      _recentlyViewedProducts = recentData.map((e) => jsonDecode(e)).toList();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_bannerController.hasClients) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _bannerController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = false;
        });
        widget.onBottomNavVisibilityChanged(false);
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = true;
        });
        widget.onBottomNavVisibilityChanged(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_isAppBarVisible ? kToolbarHeight : 0.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          height: _isAppBarVisible ? kToolbarHeight : 0.0,
          child: _isAppBarVisible
              ? AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5), // Add 5px padding
                      child: Text(
                        "Chào mừng $_userName",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecentlyViewed(),
                _buildBanner(),
                const SizedBox(height: 30),
                _buildWeeklySelection(),
                _buildLatestCollections(),
                _buildInspirations(),
                _buildQuatang(),
                _buildTraiNghiem(),
                _buildFashionShow(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          const Positioned(
            bottom: -0.4,
            left: 0,
            right: 0,
            child: AnimatedSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewed() {
  final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

  if (_recentlyViewedProducts.isEmpty) {
    return const SizedBox(); // Ẩn toàn bộ nếu không có sản phẩm
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          "Xem gần đây",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      SizedBox(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _recentlyViewedProducts.length,
          itemBuilder: (context, index) {
            var product = _recentlyViewedProducts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductPage(product: product),
                  ));
                },
                child: Container(
                  width: 230,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          product["hinhAnh"] ?? "",
                          width: 230,
                          height: 210,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            "assets/images/sp_1.jpg",
                            width: 230,
                            height: 210,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                        child: Text(
                          product["ten"] ?? "",
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3, left: 5),
                        child: Text(
                          currency.format((product["gia"] ?? 0) * 100000),
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 30),
    ],
  );
}


  /// ✅ **Banner đơn có chữ đè lên ảnh**
Widget _buildBanner() {
  List<Map<String, String>> banners = [
    {
      "image": "assets/images/Banner_7.jpg",
      "title": "Xu hướng hiện nay: Bộ sưu tập mùa thu",
      "subtitle": "Mua sắm ngay"
    },
    {
      "image": "assets/images/Banner_11.jpg",
      "title": "Vẻ đẹp cổ điển vượt thời gian",
      "subtitle": "Trang sức tinh xảo, dành riêng cho bạn"
    },
    {
      "image": "assets/images/Banner_12.jpg",
      "title": "Tỏa sáng trong từng khoảnh khắc",
      "subtitle": "Khám phá những thiết kế độc quyền"
    },
  ];

  return SizedBox(
    height: 600,
    child: Stack(
      children: [
        PageView.builder(
          controller: _bannerController,
          itemCount: banners.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final banner = banners[index];
            return Stack(
              children: [
                /// Ảnh nền
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.asset(
                    banner["image"]!,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 600,
                  ),
                ),

                /// Văn bản đè lên
                Positioned(
                  left: 20,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner["subtitle"]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner["title"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}




  Widget _buildWeeklySelection() {
  List<Map<String, String>> weeklyItems = [
    {
      "image": "assets/images/Banner_8.jpg",
      "subtext": "Khám phá sự lựa chọn",
      "title": "Mới trong: Túi xách nữ"
    },
    {
      "image": "assets/images/Banner_9.jpg",
      "subtext": "Khám phá",
      "title": "Chocolate Monogram"
    },
    {
      "image": "assets/images/Banner_10.jpg",
      "subtext": "Sắm ngay",
      "title": "Thu - Đông 2025"
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          "Lựa chọn hàng tuần",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      SizedBox(
        height: 500,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weeklyItems.length,
          itemBuilder: (context, index) {
            final item = weeklyItems[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item["image"] ?? "",
                      width: 270,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["subtext"] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    item["title"] ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

  Widget _buildLatestCollections() {
  List<Map<String, String>> collections = [
    {
      "image": "assets/images/Collec_1.jpg",
      "subtitle": "Mua sắm Bộ sưu tập",
      "title": "Muôn màu muôn vẻ"
    },
    {
      "image": "assets/images/Collec_2.jpg",
      "subtitle": "Phong cách",
      "title": "Phong cách trang sức biểu tượng"
    },
    {
      "image": "assets/images/Collec_3.jpg",
      "subtitle": "Bật mí ngay",
      "title": "Sản phẩm mới: Vòng tay & Nhẫn"
    },
    {
      "image": "assets/images/Collec_4.jpg",
      "subtitle": "Thiết kế giới hạn",
      "title": "Xuân - Hè 2025"
    },
  ];

  final PageController _controller = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Bộ sưu tập mới nhất",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 530,
            child: PageView.builder(
              controller: _controller,
              itemCount: collections.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = collections[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        /// 🔹 Ảnh nền
                        Image.asset(
                          item["image"]!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        /// 🔹 Gradient + text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["subtitle"]!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(item["title"]!, style: const TextStyle(color: Colors.white, fontSize: 20)),
                            ],
                          ),
                        ),

                        /// 🔹 Số thứ tự hình (ví dụ 1/4)
                        Positioned(
                          right: 16,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${index + 1}/${collections.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 Dots (vị trí hiện tại)
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(collections.length, (index) {
                bool isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

Widget _buildInspirations() {
  List<Map<String, String>> weeklyItems = [
    {
      "image": "assets/images/Ins_1.jpg",
      "subtext": "Đam mê",
      "title": "Sản phẩm mới: Túi nữ"
    },
    {
      "image": "assets/images/Ins_2.jpg",
      "subtext": "Sang trọng",
      "title": "Màu sắc Monogram"
    },
    {
      "image": "assets/images/Ins_3.jpg",
      "subtext": "Sắm ngay",
      "title": "Best of 2025"
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          "Nguồn cảm hứng",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      SizedBox(
        height: 500,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weeklyItems.length,
          itemBuilder: (context, index) {
            final item = weeklyItems[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item["image"] ?? "",
                      width: 350,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["subtext"] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    item["title"] ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildQuatang() {
  List<Map<String, String>> weeklyItems = [
    {
      "image": "assets/images/Qua_1.jpg",
      "subtext": "Mua liền",
      "title": "Quà tặng nàng thơ"
    },
    {
      "image": "assets/images/Qua_2.jpg",
      "subtext": "Khám phá",
      "title": "Quà tặng chàng khờ"
    },
    {
      "image": "assets/images/Qua_3.jpg",
      "subtext": "Sắm ngay",
      "title": "Quà tặng đặc biệt"
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          "Quà tặng",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      SizedBox(
        height: 500,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weeklyItems.length,
          itemBuilder: (context, index) {
            final item = weeklyItems[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item["image"] ?? "",
                      width: 350,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["subtext"] ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    item["title"] ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}


  Widget _buildTraiNghiem() {
  List<Map<String, String>> collections = [
    {
      "image": "assets/images/Trainghiem_1.jpg",
      "subtitle": "Khám phá",
      "title": "57th Lê Lợi"
    },
    {
      "image": "assets/images/Trainghiem_2.jpg",
      "subtitle": "Food & Drink",
      "title": "Le Chocolate của chúng tôi"
    },
    {
      "image": "assets/images/Trainghiem_3.jpg",
      "subtitle": "160 Năm Nghệ Thuật Kết Hợp",
      "title": "New Dream"
    },
    {
      "image": "assets/images/Trainghiem_4.jpg",
      "subtitle": "Cafe & Restaurant",
      "title": "Tinh hoa và thưởng thức"
    },
    {
      "image": "assets/images/Trainghiem_5.jpg",
      "subtitle": "Nghệ Thuật",
      "title": "Điêu khắc nghệ thuật"
    },
    {
      "image": "assets/images/Trainghiem_6.jpg",
      "subtitle": "Doanh Số Bất Phá",
      "title": "Gương mặt mới trong ngành trang sức"
    },
  ];

  final PageController _controller = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Trải Nghiệm",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 630,
            child: PageView.builder(
              controller: _controller,
              itemCount: collections.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = collections[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        /// 🔹 Ảnh nền
                        Image.asset(
                          item["image"]!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        /// 🔹 Gradient + text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["subtitle"]!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(item["title"]!, style: const TextStyle(color: Colors.white, fontSize: 20)),
                            ],
                          ),
                        ),

                        /// 🔹 Số thứ tự hình (ví dụ 1/4)
                        Positioned(
                          right: 16,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${index + 1}/${collections.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 Dots (vị trí hiện tại)
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(collections.length, (index) {
                bool isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

  Widget _buildFashionShow() {
  List<Map<String, String>> fashionItems = [
    {
      "image": "assets/images/fs_1.jpg",
      "title": "Trình diễn Mùa Thu Đông 2025"
    },
    {
      "image": "assets/images/fs_2.jpg",
      "title": "Trình diễn Mùa Xuân Hè 2025"
    },
    {
      "image": "assets/images/fs_3.jpg",
      "title": "Bộ sưu tập nổi bật"
    },
  ];

  final PageController _fashionController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  return StatefulBuilder(
    builder: (context, setState) {
      return Stack(
        children: [
          // 🔹 Background ảnh mờ
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Image.asset(
                fashionItems[_currentPage]["image"]!,
                key: ValueKey<String>(fashionItems[_currentPage]["image"]!),
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          // 🔹 Nội dung chính
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 16, bottom: 10),
                child: Text(
                  "Trình diễn thời trang",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 500,
                child: PageView.builder(
                  controller: _fashionController,
                  itemCount: fashionItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = fashionItems[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Image.asset(
                              item["image"]!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                ),
                              ),
                              child: Text(
                                item["title"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

}
