import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tsmc/database/database_helper.dart';
import 'package:tsmc/utils/mprint.dart';
// import 'package:tsmc/utils/mprint.dart';

class History extends StatelessWidget {
  const History({super.key, this.hoursAgo = 2});
  final int hoursAgo;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(hours: hoursAgo));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getWaterConsumptionRange(startTime, now),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        mprint('snapshot: ${snapshot.data}');
        final data = snapshot.data!;
        Map<double, double> intervalConsumption = {};
        
        // Initialize intervals
        for (int i = 0; i < 4; i++) {
          intervalConsumption[i * 0.5] = 0;
        }
        
        for (var record in data) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(record['timestamp'] as int);
          final minutesSinceStart = timestamp.difference(startTime).inMinutes;
          final intervalIndex = (minutesSinceStart / (hoursAgo * 15)).floor();
          if (intervalIndex < 4 && intervalIndex >= 0) {
            final amount = record['amount'] as int;
            intervalConsumption[intervalIndex * 0.5] = 
                (intervalConsumption[intervalIndex * 0.5] ?? 0) + amount;
          }
        }

        final spots = intervalConsumption.entries
            .map((entry) => FlSpot(entry.key, entry.value))
            .toList()
          ..sort((a, b) => a.x.compareTo(b.x));

        // Find maximum value for y-axis
        final maxY = spots.isEmpty ? 100.0 : max(spots.map((spot) => spot.y).reduce(max), 100.0);
        final roundedMaxY = ((maxY / 100).ceil() * 100).toDouble();
        final interval = roundedMaxY / 4;  // Divide into 4 intervals

        return SizedBox(
          width: 300,
          height: 300,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 0.5,
                      getTitlesWidget: (value, meta) {
                        final timeAtPoint = startTime.add(
                          Duration(minutes: (value * 60).toInt())
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 12,
                          child: Text(
                            '${timeAtPoint.hour.toString().padLeft(2, '0')}:${timeAtPoint.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: interval,  // Use calculated interval
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 12,
                          child: Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                minX: 0,
                maxX: 1.5,
                minY: 0,
                maxY: roundedMaxY,  // Use calculated maxY
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}