import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:tsmc/utils/mprint.dart';

void readCharacteristic(BluetoothDevice device, Guid characteristicId) async {
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid == characteristicId) {
        List<int> value = await characteristic.read();
        mprint('Read value: $value');
      }
    }
  }
}

void readServicesAndCharacteristics(BluetoothDevice device) async {
  List<BluetoothService> services = await device.discoverServices();
  for (BluetoothService service in services) {
    mprint(service.uuid.toString());
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      mprint(characteristic.uuid.toString());
    }
  }
}