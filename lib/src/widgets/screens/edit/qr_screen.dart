import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key, required this.userId});

  final int userId;
  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Scan for User ${widget.userId}"),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
          allowDuplicates: true,
          controller: cameraController,
          onDetect: _foundbarCode),
    );
  }

  _foundbarCode(Barcode barcode, MobileScannerArguments? args) {
    /// open screen
    if (!_screenOpened) {
      final String code = barcode.rawValue ?? "---";
      if (code == widget.userId.toString()) {
        // ^ GOTO OUR UPDATE PAGE
        Navigator.pushNamed(context, '/edit_user', arguments: widget.userId);
      } else {
        // ^ SHOW ERROR SNACK AND RETURN TO LIST
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: CustomSnackBar(
        //     cardColor: Color(0xFFC72C41),
        //     bubbleColor: Color(0xFF801336),
        //     title: "Oh Snap",
        //     message: "No it is not our id",
        //   ),
        //   behavior: SnackBarBehavior.floating,
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        // ));
      }
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
  }
}
