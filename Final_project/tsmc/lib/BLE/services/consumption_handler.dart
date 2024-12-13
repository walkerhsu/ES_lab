import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/BLE/services/utils.dart';
import 'package:tsmc/database/database_helper.dart';
import 'package:tsmc/utils/mprint.dart';

class WaterConsumptionDisplay extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const WaterConsumptionDisplay({
    super.key,
    required this.characteristic,
  });

  @override
  State<WaterConsumptionDisplay> createState() => _WaterConsumptionDisplayState();
}

class _WaterConsumptionDisplayState extends State<WaterConsumptionDisplay> {
  num totalWaterConsumption = 0;
  bool showHistory = false;
  int? lastProcessedValue;

  @override
  void initState() {
    super.initState();
    _getTotalWaterConsumption();
  }

  void _getTotalWaterConsumption() async {
    // get the total water consumption from 00:00 today to now
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final data = await DatabaseHelper.instance.getWaterConsumptionRange(start, now);
    mprint('data: $data');
    totalWaterConsumption = data.fold(0, (sum, record) => sum + record['amount']);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: getStreamFromCharacteristic(widget.characteristic),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final newValue = snapshot.data![1];
          mprint("newValue: ${snapshot.data}");
          totalWaterConsumption += newValue;
          lastProcessedValue = newValue;
          DatabaseHelper.instance.insertWaterConsumption(newValue);
        }

        return Column(
          children: [
            const Text(
              'Total Water Consumption',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '$totalWaterConsumption mL',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}