import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class OrderService {
  final String baseUrl = "${APIConfig.baseUrl}/api/orders";

  /// 🔹 Gửi yêu cầu tạo đơn hàng
  Future<Map<String, dynamic>> createOrder(
      String token, Map<String, dynamic> requestBody) async {
    final url = Uri.parse("$baseUrl/create");
    print("🚀 Gọi API: $url");

    try {
      final response = await http.post(
        url,
        headers: {
          ...APIConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "order": data["order"]};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["message"] ?? "Máy chủ lỗi: ${response.statusCode}"
        };
      }
    } catch (e) {
      print("❌ Lỗi createOrder: $e");
      return {"success": false, "message": "Không thể kết nối đến API"};
    }
  }

  /// 🔹 Lấy danh sách đơn hàng
  Future<Map<String, dynamic>> getOrders(String token) async {
    final url = Uri.parse(baseUrl);
    print("🚀 Gọi API: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          ...APIConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      );

      print("✅ Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> orderList = jsonDecode(response.body);
        return {"success": true, "orders": orderList};
      } else {
        final error = jsonDecode(response.body);
        return {
          "success": false,
          "message": error["message"] ?? "Không thể lấy đơn hàng"
        };
      }
    } catch (e) {
      print("❌ Lỗi getOrders: $e");
      return {"success": false, "message": "Không thể kết nối đến API"};
    }
  }
}
