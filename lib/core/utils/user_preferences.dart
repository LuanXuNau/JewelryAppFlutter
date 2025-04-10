import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUserData({
    required String token,
    required String idNguoidung,
    required String userName,
    required String phone,
    required String address,
    required String email,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Debug log
    print("🔹 Lưu Token vào SharedPreferences: $token");
    print("🔹 Lưu ID Người Dùng vào SharedPreferences: $idNguoidung");
    print("🔹 Lưu Tên Người Dùng vào SharedPreferences: $userName");
    print("🔹 Lưu SĐT vào SharedPreferences: $phone");
    print("🔹 Lưu Địa chỉ vào SharedPreferences: $address");
    

    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("token", token);
    await prefs.setString("idNguoidung", idNguoidung);
    await prefs.setString("userName", userName);
    await prefs.setString("phone", phone);
    await prefs.setString("address", address);
    await prefs.setString("email", email);

    // Kiểm tra lại sau khi lưu
    String savedToken = prefs.getString("token") ?? "";
    String savedIdNguoidung = prefs.getString("idNguoidung") ?? "";
    String savedUserName = prefs.getString("userName") ?? "Guest";
    String savedPhone = prefs.getString("phone") ?? "N/A";
    String savedAddress = prefs.getString("address") ?? "Unknown";
    String savedEmail = prefs.getString("email") ?? "No Email";

    print("🔍 Token đã lưu: '$savedToken'");
    print("🔍 ID Người Dùng đã lưu: '$savedIdNguoidung'");
    print("🔍 Tên Người Dùng đã lưu: '$savedUserName'");
    print("🔍 SĐT đã lưu: '$savedPhone'");
    print("🔍 Địa chỉ đã lưu: '$savedAddress'");
    print("🔍 Email đã lưu: '$savedEmail'");
  }

  static Future<Map<String, String>> getUserData() async {
  try {
    print("🔹 Đang lấy dữ liệu từ SharedPreferences...");
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String token = prefs.getString("token") ?? "";
    String idNguoidung = prefs.getString("idNguoidung") ?? "";
    String userName = prefs.getString("userName") ?? "Guest";
    String phone = prefs.getString("phone") ?? "N/A";
    String address = prefs.getString("address") ?? "Unknown";
    String email = prefs.getString("email") ?? "No Email";

    print("✅ Token lấy từ SharedPreferences: '$token'");
    print("✅ ID người dùng lấy từ SharedPreferences: '$idNguoidung'");
    print("✅ Tên Người Dùng lấy từ SharedPreferences: '$userName'");
    print("✅ SĐT lấy từ SharedPreferences: '$phone'");
    print("✅ Địa chỉ lấy từ SharedPreferences: '$address'");
    print("✅ Email lấy từ SharedPreferences: '$email'");

    return {
      "token": token,
      "idNguoidung": idNguoidung,
      "userName": userName,
      "phone": phone,
      "address": address,
      "email": email,
    };
  } catch (e) {
    print("❌ Lỗi khi lấy dữ liệu từ SharedPreferences: $e");
    return {
      "token": "",
      "idNguoidung": "",
      "userName": "Guest",
      "phone": "N/A",
      "address": "Unknown",
      "email": "No Email",
    };
  }
}


  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("isLoggedIn");
    await prefs.remove("token");
    await prefs.remove("idNguoidung");
    await prefs.remove("userName");
    await prefs.remove("phone");
    await prefs.remove("address");
    await prefs.remove("email");

    print("✅ Đã xóa toàn bộ dữ liệu đăng nhập!");
  }
}