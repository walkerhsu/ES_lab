import 'package:flutter/material.dart';
import 'package:tsmc/BLE/widgets/history.dart';
import 'package:tsmc/BLE/widgets/time_selector.dart';

class ShowHistory extends StatefulWidget {
  const ShowHistory({super.key});

  @override
  State<ShowHistory> createState() => _ShowHistoryState();
}

class _ShowHistoryState extends State<ShowHistory> {
  bool showHistory = false;
  int hoursAgo = 2;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimeSelector(
          selectedHours: hoursAgo,
          onHoursChanged: (hours) {
            setState(() {
              hoursAgo = hours;
            });
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart),
            const SizedBox(width: 8),
            const Text('History'),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: showHistory,
                onChanged: (bool value) {
                  setState(() {
                    showHistory = value;
                  });
                },
                activeColor: Colors.blue,
                activeTrackColor: Colors.blue.withOpacity(0.5),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (showHistory) History(hoursAgo: hoursAgo),
      ],
    );
  }
}