import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ProductService {
  final String baseUrl = APIConfig.baseUrl;

  void printBaseUrl() {
    print("🌐 API Base URL: $baseUrl");
  }

  bool _isJsonResponse(http.Response response) {
    final contentType = response.headers['content-type'];
    return contentType != null && contentType.contains('application/json');
  }

  /// ✅ Lấy tất cả sản phẩm (có phân trang)
  Future<List<dynamic>> getAllProducts(int page, int pageSize) async {
    final url =
        Uri.parse('$baseUrl/api/products?page=$page&pageSize=$pageSize');
    print("📡 Gọi GET: $url");

    try {
      final response = await http.get(url, headers: APIConfig.defaultHeaders);
      print("📥 Trạng thái: ${response.statusCode}");

      if (!_isJsonResponse(response)) {
        throw Exception("❌ Phản hồi không phải JSON hợp lệ");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception("❌ Lỗi ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("❌ Lỗi kết nối API: $e");
    }
  }

  /// ✅ Lấy sản phẩm liên quan theo categoryId
  Future<List<dynamic>> getRelatedProducts(String categoryId) async {
    final url = Uri.parse('$baseUrl/api/products/category/$categoryId?limit=4');

    try {
      final response = await http.get(url, headers: APIConfig.defaultHeaders);

      if (!_isJsonResponse(response)) {
        throw Exception("❌ Phản hồi không phải JSON hợp lệ");
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('❌ Lỗi ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❌ Lỗi kết nối API: $e');
    }
  }

  /// ✅ Lấy sản phẩm theo loại
  Future<Map<String, dynamic>> getProductsByCategory(
      String categoryId, int page, int pageSize) async {
    final url = Uri.parse(
        '$baseUrl/api/products/category/$categoryId?page=$page&pageSize=$pageSize');

    try {
      final response = await http.get(url, headers: APIConfig.defaultHeaders);

      if (!_isJsonResponse(response)) {
        throw Exception("❌ Phản hồi không phải JSON hợp lệ");
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Lỗi ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': '❌ Lỗi kết nối API: $e'};
    }
  }

  /// ✅ Tìm kiếm sản phẩm
  Future<Map<String, dynamic>> searchProducts(String keyword) async {
    final url = Uri.parse('$baseUrl/api/products/search?keyword=$keyword');

    try {
      final response = await http.get(url, headers: APIConfig.defaultHeaders);

      if (!_isJsonResponse(response)) {
        throw Exception("❌ Phản hồi không phải JSON hợp lệ");
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Lỗi ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': '❌ Lỗi kết nối API: $e'};
    }
  }

  /// ✅ Lấy sản phẩm theo thương hiệu
  Future<Map<String, dynamic>> getProductsByBrand(
      String brandId, int page, int pageSize) async {
    final url = Uri.parse(
        '$baseUrl/api/products/brand/$brandId?page=$page&pageSize=$pageSize');

    try {
      final response = await http.get(url, headers: APIConfig.defaultHeaders);

      if (!_isJsonResponse(response)) {
        throw Exception("❌ Phản hồi không phải JSON hợp lệ");
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': 'Lỗi ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': '❌ Lỗi kết nối API: $e'};
    }
  }

  /// ✅ Lấy chi tiết sản phẩm theo ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    final url = Uri.parse('$baseUrl/api/products/$productId');
    print("🔍 Gọi API lấy sản phẩm theo ID: $url");

    try {
      final response = await http.get(url, headers: APIConfig.defaultHeaders);

      if (!_isJsonResponse(response)) {
        throw Exception("❌ Phản hồi không phải JSON hợp lệ");
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("❌ Không tìm thấy sản phẩm ID: $productId");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi khi lấy sản phẩm: $e");
      return null;
    }
  }
}
