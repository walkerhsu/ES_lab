import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tsmc/redux/states/app_state.dart';
import 'package:tsmc/redux/actions/connection_actions.dart';
import 'package:tsmc/BLE/services/test.dart';

class ConnectingModal extends StatefulWidget {
  final BluetoothDevice device;
  const ConnectingModal({super.key, required this.device});

  @override
  State<ConnectingModal> createState() => _ConnectingModalState();
}

class _ConnectingModalState extends State<ConnectingModal> {
  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override

  Future<void> _connect() async {
    try {
      await widget.device.connect();
      if (!mounted) return;
      
      // Update Redux state
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(
        UpdateConnectionStateAction(
          BluetoothConnectionState.connected,
          widget.device
        )
      );

      // Navigate to TestService
      Navigator.of(context).pop(); // Close modal
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestService(device: widget.device)
        )
      );
    } catch (e) {
      if (!mounted) return;
      
      StoreProvider.of<AppState>(context).dispatch(
        UpdateConnectionStateAction(
          BluetoothConnectionState.disconnected,
          null
        )
      );
      
      Navigator.of(context).pop(); // Close modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: StreamBuilder<BluetoothConnectionState>(
          stream: widget.device.connectionState,
          builder: (c, snapshot) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  snapshot.data == BluetoothConnectionState.connected 
                    ? 'Connected!' 
                    : 'Connecting...',
                  style: const TextStyle(color: Color(0xFFEDEDED)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}