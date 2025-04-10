import 'dart:typed_data';
import 'package:http/http.dart' as http;

class RemoveBgService {
  static const String apiKey = 'zsoo6PoNSTQQBqsGF5SPdatX';

  static Future<Uint8List?> removeBackground(String imageUrl) async {
    final uri = Uri.parse('https://api.remove.bg/v1.0/removebg');
    final response = await http.post(
      uri,
      headers: {
        'X-Api-Key': apiKey,
      },
      body: {
        'image_url': imageUrl,
        'size': 'auto',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // Đây là ảnh PNG đã xóa nền
    } else {
      print("❌ Lỗi remove.bg: ${response.statusCode} - ${response.body}");
      return null;
    }
  }
}
