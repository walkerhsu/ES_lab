import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/BLE/services/utils.dart';
import 'package:tsmc/BLE/widgets/reminder.dart';
import 'package:tsmc/utils/mprint.dart';

class ReminderHandler extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const ReminderHandler({
    super.key,
    required this.characteristic,
  });

  @override
  State<ReminderHandler> createState() => _ReminderHandlerState();
}

class _ReminderHandlerState extends State<ReminderHandler> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: getStreamFromCharacteristic(widget.characteristic),
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
    );
  }
}