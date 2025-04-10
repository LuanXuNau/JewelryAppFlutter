import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CartService {
  static const String baseUrl = "${APIConfig.baseUrl}/api/cart";
  static const Map<String, String> defaultHeaders = APIConfig.defaultHeaders;

  Future<Map<String, dynamic>> fetchCart(String token) async {
    try {
      print("🚀 Gọi API: $baseUrl");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          ...defaultHeaders,
          "Authorization": "Bearer $token",
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message":
              jsonDecode(response.body)["message"] ?? "Lỗi khi lấy giỏ hàng"
        };
      }
    } catch (e) {
      print("❌ Lỗi fetchCart: $e");
      return {"success": false, "message": "Không thể kết nối đến API!"};
    }
  }

  Future<http.Response> addToCart(
      String token, String productId, int quantity) async {
    final Uri url = Uri.parse("$baseUrl/add");

    print("🚀 Gọi API: $url");

    final response = await http.post(
      url,
      headers: {
        ...defaultHeaders,
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "productId": productId,
        "quantity": quantity,
      }),
    );

    print("✅ Phản hồi: ${response.statusCode}");
    return response;
  }

  Future<Map<String, dynamic>> updateCart(
      String token, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/update");
    print("🚀 Gọi API: $url");

    try {
      final response = await http.put(
        url,
        headers: {
          ...defaultHeaders,
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "Cập nhật giỏ hàng thành công!"};
      } else {
        return {
          "success": false,
          "message":
              jsonDecode(response.body)["message"] ?? "Không thể cập nhật"
        };
      }
    } catch (e) {
      print("❌ Lỗi updateCart: $e");
      return {"success": false, "message": "Không thể kết nối đến API!"};
    }
  }

  Future<Map<String, dynamic>> removeFromCart(String productId) async {
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
          ...defaultHeaders,
          "Authorization": "Bearer $token",
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "Đã xóa sản phẩm khỏi giỏ hàng!"};
      } else {
        final decoded = jsonDecode(response.body);
        return {
          "success": false,
          "message": decoded["message"] ?? "Lỗi không xác định"
        };
      }
    } catch (e) {
      print("❌ Lỗi removeFromCart: $e");
      return {"success": false, "message": "Lỗi khi kết nối đến server!"};
    }
  }

  Future<Map<String, dynamic>> clearCart(String token) async {
    final url = Uri.parse("$baseUrl/clear");
    print("🚀 Gọi API: $url");

    try {
      final response = await http.delete(
        url,
        headers: {
          ...defaultHeaders,
          "Authorization": "Bearer $token",
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "Giỏ hàng đã được xóa!"};
      } else {
        return {
          "success": false,
          "message":
              jsonDecode(response.body)["message"] ?? "Không thể xóa giỏ hàng"
        };
      }
    } catch (e) {
      print("❌ Lỗi clearCart: $e");
      return {"success": false, "message": "Không thể kết nối đến API!"};
    }
  }
}
