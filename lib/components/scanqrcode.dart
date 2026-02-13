import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanqrcode extends StatefulWidget {
  const Scanqrcode({super.key});

  @override
  State<Scanqrcode> createState() => _ScanqrcodeState();
}

class _ScanqrcodeState extends State<Scanqrcode> {
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: true
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (!hasScanned) {
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              hasScanned = true;
              final String scannedValue = barcodes.first.rawValue!;
              // Pop and return the scanned PatientID.
              Navigator.pop(context, scannedValue);
            }
          }
        },
      ),
    );
  }
}
