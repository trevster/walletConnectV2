import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraQrView extends StatefulWidget {
  const CameraQrView({Key? key}) : super(key: key);

  @override
  State<CameraQrView> createState() => _CameraQrViewState();
}

class _CameraQrViewState extends State<CameraQrView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: MobileScanner(
        allowDuplicates: false,
        onDetect: (Barcode barcode, MobileScannerArguments? args) {
          if (barcode.rawValue?.startsWith('wc',0) != true) {showSnackBar(); return;}
          if (kDebugMode) {
            print('Raw barcode value: ${barcode.rawValue}');
          }
          Navigator.of(context).pop(barcode.rawValue);
        },
      ),
    );
  }

  void showSnackBar(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Unrecognized QR Code'),
        backgroundColor: Colors.red.shade100,
      ),
    );
  }
}
