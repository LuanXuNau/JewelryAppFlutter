class APIConfig {
  static const String baseUrl =
      "https://3cd0-113-161-94-80.ngrok-free.app";

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'User-Agent': 'Mozilla/5.0 FlutterWeb',
    'ngrok-skip-browser-warning': 'true',
  };
}
