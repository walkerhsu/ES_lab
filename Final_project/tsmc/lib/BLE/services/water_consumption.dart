import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/utils/mprint.dart';
import 'package:tsmc/BLE/services/utils.dart';
import 'package:tsmc/BLE/services/constant.dart';
import 'package:tsmc/BLE/widgets/set_time_interval.dart';
import 'package:tsmc/BLE/services/history_handler.dart';
import 'package:tsmc/BLE/services/consumption_handler.dart';
import 'package:tsmc/BLE/services/reminder_handler.dart';
import 'package:tsmc/BLE/widgets/reminder.dart';
import 'package:tsmc/database/database_helper.dart';

class WaterConsumptionPage extends StatefulWidget {
  const WaterConsumptionPage({super.key, required this.service});
  final BluetoothService service;

  @override
  State<WaterConsumptionPage> createState() => _WaterConsumptionPageState();
}

class _WaterConsumptionPageState extends State<WaterConsumptionPage> {
  late BluetoothCharacteristic? consumptionCharacteristic;
  late BluetoothCharacteristic? timeIntervalCharacteristic;
  late BluetoothCharacteristic? reminderCharacteristic;
  int interval = 0;

  @override
  void initState() {
    super.initState();
    _setupCharacteristics();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupCharacteristics() async {
    for (BluetoothCharacteristic characteristic
        in widget.service.characteristics) {
      // mprint("characteristic: ${characteristic.uuid.toString()}");
      if (characteristic.uuid.toString() ==
          Constant.waterConsumptionCharacteristic) {
        consumptionCharacteristic = characteristic;
        if (characteristic.properties.notify) {
          subscribeToNotifications(characteristic);
        }
      } else if (characteristic.uuid.toString() ==
          Constant.timeIntervalCharacteristic) {
        timeIntervalCharacteristic = characteristic;
      } else if (characteristic.uuid.toString() ==
          Constant.reminderCharacteristic) {
        reminderCharacteristic = characteristic;
        if (characteristic.properties.notify) {
          subscribeToNotifications(characteristic);
        }
      }
    }
  }

  Future<void> _setTimeInterval(int minutes) async {
    if (timeIntervalCharacteristic != null) {
      // Convert minutes to bytes and write to characteristic
      List<int> value = [
        minutes
      ]; // Adjust byte conversion based on your protocol
      await timeIntervalCharacteristic!.write(value);
      // setState(() {
      //   interval = minutes;
      // });
    }
  }

  void _showSetTimeIntervalModal() {
    showDialog(
      context: context,
      builder: (context) => SetTimeIntervalModal(
        onTimeSelected: _setTimeInterval,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          if (consumptionCharacteristic != null)
            WaterConsumptionDisplay(
              characteristic: consumptionCharacteristic!,
            ),
          const SizedBox(height: 20),
          const ShowHistory(),
          const SizedBox(height: 20),
          if (reminderCharacteristic != null)
            ReminderHandler(
              characteristic: reminderCharacteristic!,
              writeCharacteristic: timeIntervalCharacteristic!,
            ),
          // ElevatedButton(
          //     onPressed: DatabaseHelper.instance.clearDatabase,
          //     child: const Text("test"))
          StreamBuilder<List<int>>(
            stream: getStreamFromCharacteristic(reminderCharacteristic!),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                mprint('reminder handler: ${snapshot.data![1]}');
                if (snapshot.data![1] == 0) {
                  return Reminder(
                    key: UniqueKey(),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
