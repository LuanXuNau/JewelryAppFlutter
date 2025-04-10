import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_trangsuc_vs2/core/utils/user_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  final String baseUrl = APIConfig.baseUrl;
  final Map<String, String> headers = APIConfig.defaultHeaders;

  Future<Map<String, dynamic>> fetchLogin(
      String email, String password, bool remember) async {
    try {
      print("🚀 Gọi API: $baseUrl/api/auth/login");

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: jsonEncode({
          "email": email,
          "password": password,
          "remember": remember,
        }),
      );

      print("📥 Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("token") && data.containsKey("user")) {
          return {
            "success": true,
            "message": "Đăng nhập thành công!",
            "token": data["token"],
            "user": Map<String, dynamic>.from(data["user"]),
          };
        }
        throw Exception("Thiếu token hoặc thông tin user!");
      }

      final error = jsonDecode(response.body);
      return {
        "success": false,
        "message": error["message"] ?? "Lỗi không xác định!",
      };
    } catch (e) {
      print("❌ Lỗi fetchLogin: $e");
      return {
        "success": false,
        "message": "Không thể kết nối API",
        "error": e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      print("🚀 Gọi API: $baseUrl/api/auth/login");

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: jsonEncode({"email": email, "password": password}),
      );

      print("📥 Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await UserPreferences.saveUserData(
          token: data["token"],
          idNguoidung: data["user"]["idNguoidung"],
          userName: data["user"]["userName"],
          phone: data["user"]["phone"],
          address: data["user"]["address"],
          email: data["user"]["email"],
        );
        return {"success": true, "token": data["token"]};
      }

      return {"success": false, "message": "Đăng nhập thất bại"};
    } catch (e) {
      print("❌ Lỗi loginUser: $e");
      return {"success": false, "message": "Không thể kết nối đến API"};
    }
  }

  Future<Map<String, dynamic>> registerUser(String name, String email,
      String password, String phone, String address) async {
    try {
      print("🚀 Gọi API: $baseUrl/api/auth/register");

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: headers,
        body: jsonEncode({
          "Ten": name,
          "Email": email,
          "Password": password,
          "Sdt": phone,
          "Diachi": address,
        }),
      );

      print("📥 Phản hồi: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": data["message"] ?? "Đăng ký thành công!",
          "token": data["token"],
        };
      }

      final data = jsonDecode(response.body);
      return {
        "success": false,
        "message": _extractErrors(data),
      };
    } catch (e) {
      print("❌ Lỗi registerUser: $e");
      return {
        "success": false,
        "message": "Không thể kết nối đến API",
        "error": e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String phone, String newPassword) async {
    try {
      print("🚀 Gọi API: $baseUrl/api/auth/reset-password");

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: headers,
        body: jsonEncode({
          "Email": email,
          "soDienThoai": phone,
          "NewPassword": newPassword,
        }),
      );

      print("📥 Phản hồi: ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      }

      return {
        "success": false,
        "message": _extractErrors(data),
      };
    } catch (e) {
      print("❌ Lỗi resetPassword: $e");
      return {
        "success": false,
        "message": "Không thể kết nối đến API",
        "error": e.toString()
      };
    }
  }

  Future<Map<String, dynamic>> verifyUser(String email, String phone) async {
    try {
      print("🚀 Gọi API: $baseUrl/api/auth/verify-user");

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-user'),
        headers: headers,
        body: jsonEncode({
          "email": email,
          "sdt": phone,
        }),
      );

      print("📥 Phản hồi: ${response.statusCode}");

      return jsonDecode(response.body);
    } catch (e) {
      print("❌ Lỗi verifyUser: $e");
      return {
        "success": false,
        "message": "Không thể kết nối đến API",
        "error": e.toString()
      };
    }
  }

  String _extractErrors(Map<String, dynamic> data) {
    if (data.containsKey("errors")) {
      List<String> messages = [];
      data["errors"].forEach((key, value) {
        if (value is List) {
          messages.addAll(value.map((v) => "$key: $v"));
        }
      });
      return messages.isNotEmpty ? messages.join("\n") : "Lỗi không xác định!";
    }
    return data["message"] ?? "Lỗi không xác định!";
  }
}
