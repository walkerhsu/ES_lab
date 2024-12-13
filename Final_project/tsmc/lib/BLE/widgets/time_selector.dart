import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final int selectedHours;
  final Function(int) onHoursChanged;
  final List<int> availableHours;

  const TimeSelector({
    super.key,
    required this.selectedHours,
    required this.onHoursChanged,
    this.availableHours = const [1, 2, 4, 8, 12],
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: availableHours.length,
          itemBuilder: (context, index) {
            final hours = availableHours[index];
            final isSelected = hours == selectedHours;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onHoursChanged(hours),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${hours}h',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}