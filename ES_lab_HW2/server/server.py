import socket
import time
from matplotlib import pyplot as plt

class WifiServer:
    def __init__(self, host='0.0.0.0', port=8080):
        """Initialize the WiFi server with a given host and port."""
        self.host = host
        self.port = port
        self.server_socket = None
        self.acc_x_list = []
        self.acc_y_list = []
        self.acc_z_list = []

    def start_server(self):
        """Start the server and listen for incoming connections."""
        try:
            # Create a TCP socket
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

            # Bind the socket to the provided host and port
            self.server_socket.bind((self.host, self.port))

            # Listen for incoming connections (max 1 connection in this example)
            self.server_socket.listen(1)
            print(f"Server started on {self.host}:{self.port}, waiting for connection...")

            # Accept the connection from the STM32 client
            print("Waiting for connection...")
            client_socket, client_address = self.server_socket.accept()
            print("Connection established with", client_address)
            # print(f"Connection established with {client_address}")

            # Communicate with the client (STM32)
            self.handle_client(client_socket)

        except Exception as e:
            print(f"Error: {e}")
        finally:
            self.stop_server()

    def handle_client(self, client_socket):
        """Handle communication with the connected STM32 client."""
        try:
            while True:
                # Receive data from the client
                data = client_socket.recv(1024)
                print(data)
                if not data:
                    break
                data = data.decode().strip().strip('\n').split(' ')
                acc_x = float(data[0])
                acc_y = float(data[1])
                acc_z = float(data[2])
                print(f"Received from STM32: {acc_x}, {acc_y}, {acc_z}")
                self.acc_x_list.append(acc_x)
                self.acc_y_list.append(acc_y)
                self.acc_z_list.append(acc_z)
                self.plot_data()

        except Exception as e:
            print(f"Error communicating with client: {e}")
        finally:
            client_socket.close()

    def stop_server(self):
        """Stop the server and clean up."""
        if self.server_socket:
            self.server_socket.close()
            print("Server stopped.")
        self.plot_data()

    def plot_data(self):
        plt.figure(figsize=(10, 6))
        plt.plot(self.acc_x_list, label='Acceleration X')
        plt.plot(self.acc_y_list, label='Acceleration Y')
        plt.plot(self.acc_z_list, label='Acceleration Z')
        plt.xlabel('Time')
        plt.ylabel('Acceleration (mg)')
        plt.legend()
        plt.savefig('acc_data.png')
        plt.close()


if __name__ == "__main__":
    # Instantiate and start the server
    wifi_server = WifiServer(host='172.20.10.6', port=8080)
    wifi_server.start_server()
