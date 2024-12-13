import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppState {
  final BluetoothConnectionState connectionState;
  final BluetoothDevice? connectedDevice;
  final bool shouldRemind;

  AppState({
    this.connectionState = BluetoothConnectionState.disconnected,
    this.connectedDevice,
    this.shouldRemind = false,
  });

  AppState copyWith({
    BluetoothConnectionState? connectionState,
    BluetoothDevice? connectedDevice,
    bool? shouldRemind,
  }) {
    return AppState(
      connectionState: connectionState ?? this.connectionState,
      connectedDevice: connectedDevice == null ? null : this.connectedDevice,
      shouldRemind: shouldRemind ?? this.shouldRemind,
    );
  }
} 