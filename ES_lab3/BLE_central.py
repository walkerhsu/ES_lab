from bluepy.btle import Peripheral, UUID, Descriptor
from bluepy.btle import Scanner, DefaultDelegate

class ScanDelegate(DefaultDelegate):
    def __init__(self):
        DefaultDelegate.__init__(self)
    def handleDiscovery(self, dev, isNewDev, isNewData):
        if isNewDev:
            print ("Discovered device", dev.addr)
        elif isNewData:
            print ("Received new data from", dev.addr)
    def handleNotification(self, chandle, data):
        print(f"Notification received from handle {chandle}: {data}")

# 掃描設備
scanner = Scanner().withDelegate(ScanDelegate())
devices = scanner.scan(0.5)

n = 0
addr = []
print("devices:", devices)
number = 0
for dev in devices:
    print("%d: Device %s (%s), RSSI=%d dB" % (n, dev.addr, dev.addrType, dev.rssi))
    addr.append(dev.addr)
    n += 1
    for (adtype, desc, value) in dev.getScanData():
        print(" %s = %s" % (desc, value))
        if value == "Blank":
            number = n-1

# 用户选择设备
# number = input('Enter your device number: ')
print('Device', number)
num = int(number)
print(addr[num])

# 连接设备
print("Connecting...")
dev = Peripheral(addr[num], 'random')
dev.setDelegate(ScanDelegate())

# 列出设备的所有服务
print("Services...")
for svc in dev.services:
    print(str(svc))

try:
    # 获取目标服务 (UUID = 0x)
    testService = dev.getServiceByUUID(UUID(0x1111))
    for ch in testService.getCharacteristics():
        print(str(ch))
    
    # 获取目标特征 (UUID = 0xfff1)
    ch = dev.getCharacteristics(uuid=UUID(0x2222))[0]
    
    # 检查该特征是否支持读取
    if ch.supportsRead():
        print("Characteristic value: ", ch.read())
    
    # 设置CCCD为 0x0002 以启用通知
    cccd_uuid = 0x2902  # CCCD 的 UUID 是固定的 0x2902
    cccd_descriptor = ch.getDescriptors(forUUID=cccd_uuid)[0]
    print("Setting CCCD to enable notifications...")
    cccd_descriptor.write(b'\x02\x00', withResponse=True)  # 0x0002 启用通知

    print("CCCD set to 0x0002 for notifications.")
    while True:
        if dev.waitForNotifications(1.0):
            continue
        print("Wait for notification")
finally:
    # 断开设备连接
    dev.disconnect()
