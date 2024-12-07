import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tsmc/utils/mprint.dart';
import 'package:tsmc/BLE/scanning.dart';
// stateless widget
class BleSetup extends StatefulWidget {
  const BleSetup({super.key});
  @override
  State<BleSetup> createState() => _BleSetupState();
}

class _BleSetupState extends State<BleSetup> {

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    getPermissions();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  Future getPermissions()async{
    try {
      mprint('requesting permissions');
      final bluetoothStatus = await Permission.bluetooth.request();
      mprint('Bluetooth permission: $bluetoothStatus');
      // final bluetoothScanStatus = await Permission.bluetoothScan.request();
      // final bluetoothConnectStatus = await Permission.bluetoothConnect.request();
      // final bluetoothAdvertiseStatus = await Permission.bluetoothAdvertise.request();
    } catch (e) {
      mprint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterBluePlus.adapterState,
      builder: (context,snapshot){
        mprint(snapshot.data.toString());
        if(snapshot.data != null) {
          if(snapshot.data == BluetoothAdapterState.on){
            return const Scanning();
          }else if(snapshot.data == BluetoothAdapterState.off){
            return const Text('Bluetooth is off');
          }
        }
        return const Text('Bluetooth is unknown');
      }
    );
  }
}

