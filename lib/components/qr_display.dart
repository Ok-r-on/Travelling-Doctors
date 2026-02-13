import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRDisplay extends StatefulWidget {
  final String qrData;
  const QRDisplay({Key? key, required this.qrData}) : super(key: key);

  @override
  State<QRDisplay> createState() => _QRDisplayState();
}

class _QRDisplayState extends State<QRDisplay> {
  bool _showQR = false;
  bool _qrLoaded = false;

  // Called when the user taps the widget.
  void _triggerQRDisplay() {
    setState(() {
      _showQR = true;
      _qrLoaded = false;
    });
    // Simulate a loading delay for the QR code (e.g., waiting for asset load)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _qrLoaded = true;
        });
      }
    });
    // Hide the QR code after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showQR = false;
          _qrLoaded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerQRDisplay,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            child: Center(
              child: _showQR
                  ? _qrLoaded
                  ? PrettyQrView.data(
                  data: widget.qrData,
                  decoration: const PrettyQrDecoration(
                      background: Colors.transparent,
                      shape: PrettyQrSmoothSymbol(),
                      image: PrettyQrDecorationImage(
                          image: AssetImage('images/patient.png'),
                          position:
                          PrettyQrDecorationImagePosition.embedded)))
                  : const CircularProgressIndicator()
                  : Image.asset(
                "assets/images/patient.png",
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Text("Click Me!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
