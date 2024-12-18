import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/BLE/services/utils.dart';
import 'package:tsmc/BLE/widgets/reminder.dart';
import 'package:tsmc/utils/mprint.dart';
import 'package:tsmc/BLE/widgets/set_time_interval.dart';

class ReminderHandler extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final BluetoothCharacteristic writeCharacteristic;

  const ReminderHandler(
      {super.key,
      required this.characteristic,
      required this.writeCharacteristic});

  @override
  State<ReminderHandler> createState() => _ReminderHandlerState();
}

class _ReminderHandlerState extends State<ReminderHandler> {
  int interval = 20;

  Future<void> _setTimeInterval(int minutes) async {
    // Convert minutes to bytes and write to characteristic
    List<int> value = [
      minutes
    ]; // Adjust byte conversion based on your protocol
    await widget.writeCharacteristic.write(value);
    setState(() {
      interval = minutes;
    });
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: _showSetTimeIntervalModal,
          child: const Text('Set Reminder Interval'),
        ),
        const SizedBox(height: 20),
        ReminderText(interval: interval),
        const SizedBox(height: 20),
      ],
    );
  }
}
