import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class WishlistService {
  final String baseUrl = "${APIConfig.baseUrl}/api/wishlist";

  /// ✅ Lấy danh sách yêu thích
  Future<Map<String, dynamic>> fetchWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      return {"success": false, "message": "Bạn chưa đăng nhập!"};
    }

    final url = Uri.parse(baseUrl);
    print("🚀 Gọi API: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          ...APIConfig.defaultHeaders,
          "Authorization": "Bearer $token",
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ??
              "Lỗi khi lấy danh sách yêu thích"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Không thể kết nối đến API!"};
    }
  }

  /// ✅ Lấy sản phẩm theo ID
  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    final url = Uri.parse("${APIConfig.baseUrl}/api/products/$productId");
    print("🚀 Gọi API: $url");

    try {
      final response = await http.get(
        url,
        headers: APIConfig.defaultHeaders,
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// ✅ Thêm vào yêu thích
  Future<Map<String, dynamic>> addToWishlist(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      return {"success": false, "message": "Bạn chưa đăng nhập!"};
    }

    final url = Uri.parse("$baseUrl/add/$productId");
    print("🚀 Gọi API: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          ...APIConfig.defaultHeaders,
          "Authorization": "Bearer $token"
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "Đã thêm vào danh sách yêu thích!"};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ??
              "Không thể thêm vào danh sách yêu thích"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Không thể kết nối đến API!"};
    }
  }

  /// ✅ Xóa khỏi yêu thích
  Future<Map<String, dynamic>> removeFromWishlist(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      return {"success": false, "message": "Bạn chưa đăng nhập!"};
    }

    final url = Uri.parse("$baseUrl/remove/$productId");
    print("🚀 Gọi API: $url");

    try {
      final response = await http.delete(
        url,
        headers: {
          ...APIConfig.defaultHeaders,
          "Authorization": "Bearer $token"
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "Đã xóa khỏi danh sách yêu thích!"};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          "success": false,
          "message": decoded["message"] ?? "Lỗi không xác định"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Không thể kết nối đến API!"};
    }
  }
}
