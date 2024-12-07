import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/widgets/app_bar.dart';

class TestService extends StatefulWidget {
  const TestService({super.key, required this.device});
  final BluetoothDevice device;

  @override
  State<TestService> createState() => _TestServiceState();
}

class _TestServiceState extends State<TestService> {
   late final BluetoothDevice device;

  @override
  void initState() {
    super.initState();
    device = widget.device; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: device.platformName),
      body: FutureBuilder(
        future: device.discoverServices(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<BluetoothService> services = snapshot.data!;
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                BluetoothService service = services[index];
                return ExpansionTile(
                  title: Text(
                    service.uuid.toString(),
                    style: const TextStyle(color: Color(0xFFEDEDED)),
                  ),
                  children: service.characteristics.map((c) => ListTile(
                    title: Text(
                      c.uuid.toString(),
                      style: TextStyle(
                        color: const Color(0xFFEDEDED).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Properties: ${c.properties.toString()}',
                      style: TextStyle(
                        color: const Color(0xFFEDEDED).withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  )).toList(),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}
