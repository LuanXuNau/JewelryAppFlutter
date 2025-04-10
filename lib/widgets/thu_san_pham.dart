import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_trangsuc_vs2/core/services/remove_bg_service.dart';

class TryOnCameraPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const TryOnCameraPage({super.key, required this.product});

  @override
  State<TryOnCameraPage> createState() => _TryOnCameraPageState();
}

class _TryOnCameraPageState extends State<TryOnCameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  Uint8List? _overlayImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOverlayImage();
    _initCamera();
  }

  Future<void> _loadOverlayImage() async {
    //final url = "http://localhost:5114/images/${widget.product['hinhAnh']}";
    final url = "https://i.imgur.com/CCinWyy.jpeg";
    final result = await RemoveBgService.removeBackground(url);
    setState(() {
      _overlayImage = result;
      _loading = false;
    });
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.isNotEmpty ? cameras.first : null;

      if (firstCamera != null) {
        _controller = CameraController(firstCamera, ResolutionPreset.medium);
        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;
        if (mounted) setState(() {});
      } else {
        print("Không tìm thấy camera nào.");
      }
    } catch (e) {
      print("Lỗi khởi tạo camera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCamera() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_controller!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Thử sản phẩm"),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildCamera()),
          if (_overlayImage != null)
            Center(
              child: Image.memory(
                _overlayImage!,
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}