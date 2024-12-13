import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tsmc/BLE/widgets/connecting_modal.dart';
import 'package:tsmc/redux/states/app_state.dart';

class ScannedDevices extends StatefulWidget {
  const ScannedDevices({super.key});

  @override
  State<ScannedDevices> createState() => _ScannedDevicesState();
}

class _ScannedDevicesState extends State<ScannedDevices> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // Scanned Devices Title
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Scanned Devices",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 125, 216, 255),
              ),
            ),
          ),
          // Scanned Devices StreamBuilder
          StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: const [],
            builder: (c, snapshot) {
              List<ScanResult> scanresults = snapshot.data!;
              List<ScanResult> templist = [];
              for (ScanResult element in scanresults) {
                if (element.device.platformName != "") {
                  templist.add(element);
                }
              }
              if (templist.isEmpty) {
                return const SizedBox(
                  height: 30,
                  child: Center(
                      child: Text(
                    'No devices found',
                    style: TextStyle(color: Color(0xFFEDEDED)),
                  )),
                );
              }
              return SizedBox(
                height: 700,
                child: ListView.builder(
                    itemCount: templist.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                              title: Text(
                                templist[index].device.platformName,
                                style:
                                    const TextStyle(color: Color(0xFFEDEDED)),
                              ),
                              leading: Icon(
                                Icons.devices,
                                color: const Color(0xFFEDEDED).withOpacity(0.3),
                              ),
                              trailing: StoreConnector<AppState,
                                      BluetoothDevice?>(
                                  converter: (store) =>
                                      store.state.connectedDevice,
                                  builder: (context, connectedDevice) =>
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: const BorderRadius.all(
                                                      Radius.circular(8)),
                                                  side: BorderSide(
                                                      color: StoreProvider.of<AppState>(context)
                                                                  .state
                                                                  .connectedDevice ==
                                                              templist[index]
                                                                  .device
                                                          ? Colors.green
                                                          : Colors.orange))),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) =>
                                                  ConnectingModal(
                                                      device: templist[index]
                                                          .device),
                                            );
                                          },
                                          child:
                                              // check the redux state to know whether the device is connected
                                              StoreProvider.of<AppState>(context)
                                                          .state
                                                          .connectedDevice ==
                                                      templist[index].device
                                                  ? const Text('Connected!', style: TextStyle(color: Colors.green))
                                                  : const Text('Connect', style: TextStyle(color: Colors.orange))))),
                          const Divider()
                        ],
                      );
                    }),
              );
            },
          ),
        ],
      ),
    );
  }
}
