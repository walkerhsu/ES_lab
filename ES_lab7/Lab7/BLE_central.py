from bluepy.btle import Peripheral, UUID, Descriptor
from bluepy.btle import Scanner, DefaultDelegate
from bluepy import btle
import struct
import threading

class ScanDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)
    def handleDiscovery(self, dev, isNewDev, isNewData):
        if isNewDev:
            print ("Discovered device", dev.addr)
        elif isNewData:
            print ("Received new data from", dev.addr)
    def handleNotification(self, chandle, data):
        # Data format should match what STM32 sends (e.g., 3 16-bit integers for acceleration)
        iffilter = struct.unpack('>h', data)
        z_accel_values = struct.unpack('>' + 'h' * 32, data)
        # accel_x, accel_y, accel_z = struct.unpack('>hhh', data)  # assuming little-endian and 16-bit signed values
        print(f"Received data is {'filtered' if iffilter else 'unfiltered'}")
        for z_value in z_accel_values:
            print(z_value)
        print("End of receiving data")

def input_thread(dev, freq_char, freq_read_char):
    """Thread function to capture user input and change the sampling frequency."""
    while True:
        try:
            # Capture user input and set new sampling frequency
            in_freq = input("Enter new sampling frequency (> 100ms): ")
            if in_freq.isdigit():
                new_freq = struct.pack('<H', int(in_freq) // 100)  # Assuming 16-bit unsigned integer for frequency
                # freq_char.write(new_freq, withResponse=False)
                freq_handle = freq_char.getHandle() # Get the handle associated with the UUID
                dev.writeCharacteristic(freq_handle, new_freq, withResponse=False)
                print(f"Set sampling interval to {in_freq} ms.")
                # freq_value_hex = freq_read_char.read()
                # freq_value = struct.unpack('>I', freq_value_hex)[0]
                # print(f"Current sampling interval : {freq_value} ms")
                
            else:
                print("Invalid input. Please enter a valid integer.")
        except KeyboardInterrupt:
            print("Exiting thread.")
            break

# 掃描設備
scanner = Scanner().withDelegate(ScanDelegate())
devices = scanner.scan(5.0)

n = 0
addr = []
print("devices:", devices)
num = -1
for dev in devices:
    print("%d: Device %s (%s), RSSI=%d dB" % (n, dev.addr, dev.addrType, dev.rssi))
    addr.append(dev.addr)
    n += 1
    for (adtype, desc, value) in dev.getScanData():
        print(" %s = %s" % (desc, value))
        if value == "BlueNRG":
            print("BlueNRG device found")
            num = n-1

# choose the device
# num = input('Enter your device number: ')
print('Device', num)
num = int(num)
print(addr[num])

# connecting
print("Connecting to STM32...")
dev = Peripheral(addr[num], 'random')
dev.setDelegate(ScanDelegate())

# UUID for the service
svc_index = 0
print("Services...")
for svc in dev.services:
    print("Service ", svc_index)
    svc_index += 1
    print(str(svc))
    
    ch_index = 0
    for ch in svc.getCharacteristics():
        print("Characteristic ", ch_index)
        ch_index += 1
        print(str(ch), ch.uuid, ch.properties, ch.propertiesToString(), f'Handle: {ch.getHandle()}', sep = ' | ')
    print()
services = list(dev.services)

try:
    # get the service
    svc_accel_index = int(input('Enter the service number: '))
    # svc_accel_index = 2
    # svc_freq_index = 3
    accel_Service = dev.getServiceByUUID(services[svc_accel_index].uuid)
    # freq_Service = dev.getServiceByUUID(services[svc_freq_index].uuid)
    
    # get the characteristics
    accel_characteristics = list(accel_Service.getCharacteristics())
    accel_char_index = int(input('Enter the accel characteristic number: '))
    # accel_char_index = 1
    # freq_read_char_index = 0
    
    # freq_characteristics = list(freq_Service.getCharacteristics())
    # freq_char_index = int(input('Enter the freq characteristic number: '))
    # freq_char_index = 0
    
    accel_char = dev.getCharacteristics(uuid=accel_characteristics[accel_char_index].uuid)[0]
    # freq_read_char = dev.getCharacteristics(uuid=accel_characteristics[freq_read_char_index].uuid)[0]
    # freq_char = dev.getCharacteristics(uuid=freq_characteristics[freq_char_index].uuid)[0]
    
    # Start the input thread for modifying sampling frequency
    # input_thread_obj = threading.Thread(target=input_thread, args=(dev, freq_char, freq_read_char))
    # input_thread_obj.daemon = True  # Daemon thread will terminate when the main program exits
    # input_thread_obj.start()
    
    # Enable notifications for the acceleration data (GATT characteristic_a)
    accel_handle = accel_char.getHandle()
    dev.writeCharacteristic(accel_handle + 1, struct.pack('<bb', 0x01, 0x00), withResponse=True)
    print("Enabled notifications for acceleration data.")
    
    # freq_value = struct.unpack('<I', freq_char.read())[0]  # '<H' for little-endian 16-bit integer
    # freq_value_hex = freq_read_char.read()
    # print(f"Current sampling interval: {struct.unpack('>I', freq_value_hex)[0]} ms")
    # print(f"Current sampling interval in Hex: {freq_value_hex}")
    
    while True:
        if dev.waitForNotifications(10.0):
            continue
        print("Wait for notification")
        pass
finally:
    # 断开设备连接
    dev.disconnect()
