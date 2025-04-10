import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PayPalService {
  final String baseUrl = APIConfig.baseUrl;

  /// ✅ Gửi yêu cầu tạo thanh toán PayPal từ ID đơn hàng
  Future<String?> createPayPalLink(String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/api/PayPal/create?idDonhang=$orderId');
      print("🔗 Gửi yêu cầu tạo link PayPal cho idDonhang: $orderId");

      final response = await http.post(
        url,
        headers: APIConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final redirectUrl = data['redirectUrl'];
        print("✅ Link redirect nhận được: $redirectUrl");
        return redirectUrl;
      } else {
        print("❌ Lỗi khi tạo PayPal link: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi kết nối PayPal API: $e");
      return null;
    }
  }
}
