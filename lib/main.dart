import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/views/home/shop_page.dart';
import 'package:ui_trangsuc_vs2/views/home/home_page.dart';
import 'package:ui_trangsuc_vs2/views/home/mylv_page.dart';
import 'package:ui_trangsuc_vs2/widgets/custom_bottom_nav.dart';
import 'package:ui_trangsuc_vs2/views/home/cart_page.dart';
import 'package:ui_trangsuc_vs2/views/mylv/my_profile_page.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await UserPreferences.clearUserData(); // Xóa dữ liệu cũ
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'BeVietnamPro',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 22),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late PageController _pageController;
  bool _isLoggedIn = false;
  String _userName = "";
  String _phone = "";
  String _address = "";
  String _email = "";
  bool _isLoading = true; // Thêm biến này để kiểm soát việc hiển thị dữ liệu
  bool _isBottomNavVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _checkLoginStatus();
  }

  /// 🔥 **Hàm kiểm tra trạng thái đăng nhập và lấy thông tin người dùng**
  Future<void> _checkLoginStatus() async {
    Map<String, String> userData = await UserPreferences.getUserData();
    setState(() {
      _isLoggedIn = userData["token"]!.isNotEmpty;
      _userName = userData["userName"]!;
      _phone = userData["phone"]!;
      _address = userData["address"]!;
      _email = userData["email"]!;
      _isLoading = false; // Dữ liệu đã sẵn sàng để hiển thị
    });
  }

  /// 🔄 **Hàm xử lý khi đổi tab**
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      // 🔥 Nếu chuyển sang MyLV, kiểm tra trạng thái đăng nhập
      _checkLoginStatus();
    }

    _pageController.jumpToPage(index);
  }

  void _onBottomNavVisibilityChanged(bool isVisible) {
    setState(() {
      _isBottomNavVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading khi chưa có dữ liệu
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                HomePage(
                    onBottomNavVisibilityChanged:
                        _onBottomNavVisibilityChanged),
                const ShopPage(),
                _isLoggedIn
                    ? MyProfilePage(
                        userName: _userName,
                        phone: _phone,
                        address: _address,
                        email: _email,
                      )
                    : const MyLVPage(),
                const CartPage(),
              ],
            ),
      bottomNavigationBar: _isBottomNavVisible
          ? CustomBottomNavBar(
              selectedIndex: _currentIndex,
              onItemTapped: _onTabTapped,
            )
          : null,
    );
  }
}
