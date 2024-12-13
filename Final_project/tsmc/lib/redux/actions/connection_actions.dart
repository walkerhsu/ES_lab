import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UpdateConnectionStateAction {
  final BluetoothConnectionState connectionState;
  final BluetoothDevice? device;

  UpdateConnectionStateAction(this.connectionState, this.device);
} 

class UpdateShouldRemindAction {
  final bool shouldRemind;
  UpdateShouldRemindAction(this.shouldRemind);
} 