import 'package:flutter/material.dart';

class SetTimeIntervalModal extends StatefulWidget {
  final Function(int) onTimeSelected;

  const SetTimeIntervalModal({super.key, required this.onTimeSelected});

  @override
  State<SetTimeIntervalModal> createState() => _SetTimeIntervalModalState();
}

class _SetTimeIntervalModalState extends State<SetTimeIntervalModal> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final interval = int.tryParse(_controller.text);
    if (interval == null || interval <= 0) {
      setState(() {
        _errorText = 'Please enter a valid positive number';
      });
      return;
    }
    widget.onTimeSelected(interval);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Reminder Interval'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Minutes',
              hintText: 'Enter time interval (e.g., 30)',
              errorText: _errorText,
              border: const OutlineInputBorder(),
              suffixText: 'min',
            ),
            onChanged: (_) => setState(() => _errorText = null),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Set'),
        ),
      ],
    );
  }
} 