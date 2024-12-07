import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppState {
  final BluetoothConnectionState connectionState;
  final BluetoothDevice? connectedDevice;

  AppState({
    this.connectionState = BluetoothConnectionState.disconnected,
    this.connectedDevice,
  });

  AppState copyWith({
    BluetoothConnectionState? connectionState,
    BluetoothDevice? connectedDevice,
  }) {
    return AppState(
      connectionState: connectionState ?? this.connectionState,
      connectedDevice: connectedDevice ?? this.connectedDevice,
    );
  }
} 