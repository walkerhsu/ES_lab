import serial

# Configure the serial port
ser = serial.Serial('COM3', baudrate=115200, timeout=1)  # Replace 'COM3' with your port
output_file = "Angular_velocity_y.txt"

with open(output_file, 'w') as file:
    while True:
        data = ser.readline().decode('utf-8')  # Read a line from STM32
        if data:
            print(data.strip())  # Display on console
            file.write(data.strip() + "\n")    # Write to file
