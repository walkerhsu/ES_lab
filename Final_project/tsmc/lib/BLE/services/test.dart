import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tsmc/redux/actions/connection_actions.dart';
import 'package:tsmc/redux/states/app_state.dart';
import 'package:tsmc/utils/mprint.dart';
import 'package:tsmc/widgets/app_bar.dart';
import 'package:tsmc/BLE/services/constant.dart';
import 'package:tsmc/BLE/services/water_consumption.dart';

class TestService extends StatefulWidget {
  const TestService({super.key, required this.device});
  final BluetoothDevice device;

  @override
  State<TestService> createState() => _TestServiceState();
}

class _TestServiceState extends State<TestService> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    mprint("in dispose function from test.dart");
    super.dispose();
    await widget.device.disconnect();
  }
  

  Future<void> _onBack() async {
    try {
      // First discover services
      List<BluetoothService> services = await widget.device.discoverServices();
      
      // Disable all notifications
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(false);
          }
        }
      }

      // Wait a bit for notifications to be disabled
      await Future.delayed(const Duration(milliseconds: 100));

      // First disconnect the device
      await widget.device.disconnect();
      
      // Then update Redux state after successful disconnection
      if (!mounted) return;
      StoreProvider.of<AppState>(context).dispatch(
        UpdateConnectionStateAction(
          BluetoothConnectionState.disconnected,
          null  // Set to null after successful disconnection
        )
      );

      mprint("connection state: ${widget.device.isConnected}");
      mprint(StoreProvider.of<AppState>(context).state.connectionState);
      mprint(StoreProvider.of<AppState>(context).state.connectedDevice);
      mprint("Redux state updated to disconnected");
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      mprint("Error disconnecting from device: $e");
      if (mounted) {
        // Still update Redux state in case of error
        StoreProvider.of<AppState>(context).dispatch(
          UpdateConnectionStateAction(
            BluetoothConnectionState.disconnected,
            null
          )
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.device.platformName, onBack: _onBack, showBackButton: true),
      body: FutureBuilder(
        future: widget.device.discoverServices(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<BluetoothService> services = snapshot.data!;
            for (BluetoothService service in services) {
              mprint(service.uuid.toString());
              if (service.uuid.toString() == Constant.waterConsumptionService) {
                return WaterConsumptionPage(service: service); 
              }
            }
          }
          return const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}
