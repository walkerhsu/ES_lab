import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/utils/mprint.dart';
import 'package:tsmc/utils/mloading.dart';
import 'package:tsmc/BLE/scanned_devices.dart';
import 'package:tsmc/widgets/app_bar.dart';


class Scanning extends StatefulWidget {
  const Scanning({super.key});

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: FlutterBluePlus.isScanning,
      initialData: false,
      builder: (c, snapshot) {
        if (snapshot.data!) {
          return Scaffold(
            appBar: const MyAppBar(showBackButton: false),
            body: const MyLoading(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => FlutterBluePlus.stopScan(),
              backgroundColor:const Color(0xFFEDEDED),
              child: const Icon(Icons.stop,color: Colors.red,),
            ),
          );
        } else {
          return Scaffold(
            appBar: const MyAppBar(showBackButton: false),
            body: const ScannedDevices(),
            floatingActionButton: FloatingActionButton(
              backgroundColor:const Color(0xFFEDEDED),
              onPressed: ()=> FlutterBluePlus.startScan(timeout: const Duration(seconds: 4)),
              child: Icon(Icons.search,color: Colors.blue.shade300,),
            ),
          );
        }
      },
    );
  }
}
