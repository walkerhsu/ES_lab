import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SelectedDevice{
  BluetoothDevice? device;
  int? state;

  SelectedDevice(this.device,this.state);
}