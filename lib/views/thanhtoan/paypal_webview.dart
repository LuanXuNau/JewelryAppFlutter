// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PayPalWebView extends StatelessWidget {
//   final String url;
//   final String orderId;

//   const PayPalWebView({super.key, required this.url, required this.orderId});

//   @override
//   Widget build(BuildContext context) {
//     final controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onNavigationRequest: (request) {
//             final navUrl = request.url;

//             if (navUrl.contains("success")) {
//               Navigator.pop(context, true); // ✅ Thành công
//               return NavigationDecision.prevent;
//             } else if (navUrl.contains("cancel")) {
//               Navigator.pop(context, false); // ❌ Hủy
//               return NavigationDecision.prevent;
//             }

//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(url));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Thanh toán PayPal"),
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//       ),
//       body: WebViewWidget(controller: controller),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaypalWebViewPage extends StatefulWidget {
  final String paypalUrl;

  const PaypalWebViewPage({super.key, required this.paypalUrl});

  @override
  State<PaypalWebViewPage> createState() => _PaypalWebViewPageState();
}

class _PaypalWebViewPageState extends State<PaypalWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Nếu là Web, mở trực tiếp bằng URL launcher
    if (kIsWeb) {
      launchUrlString(widget.paypalUrl, mode: LaunchMode.externalApplication);
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              if (request.url.contains("success")) {
                Navigator.pop(context, true); // ✅ Thành công
              } else if (request.url.contains("cancel")) {
                Navigator.pop(context, false); // ❌ Hủy
              }
              return NavigationDecision.navigate;
            },
            onWebResourceError: (error) {
              print("❌ Lỗi WebView: $error");
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paypalUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(
        body: Center(child: Text("Đang chuyển hướng đến PayPal...")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán PayPal"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
