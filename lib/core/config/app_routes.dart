import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/main.dart';
import 'package:ui_trangsuc_vs2/views/home/cart_page.dart';
import 'package:ui_trangsuc_vs2/views/home/home_page.dart';
import 'package:ui_trangsuc_vs2/views/home/mylv_page.dart';
import 'package:ui_trangsuc_vs2/views/home/shop_page.dart';

class AppRoutes {
  static const String mainScreen = '/main';
  static const String homePage = '/home';
  static const String shopPage = '/shop';
  static const String myLVPage = '/mylv';
  static const String cartPage = '/cart';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainScreen:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case homePage:
        return MaterialPageRoute(builder: (_) => HomePage(onBottomNavVisibilityChanged: (bool isVisible) {}));
      case shopPage:
        return MaterialPageRoute(builder: (_) => const ShopPage());
      case myLVPage:
        return MaterialPageRoute(builder: (_) => const MyLVPage());
      case cartPage:
       return MaterialPageRoute(builder: (_) => const CartPage());
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen());
    }
  }

  /// ✅ **Lấy token từ SharedPreferences**
 
}
