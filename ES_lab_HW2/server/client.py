import socket

host = '0.0.0.0'  # Server IP
port = 8080              # Server Port

try:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
        client_socket.connect((host, port))
        client_socket.sendall(b"Hello from Python Client!")
        response = client_socket.recv(1024)
        print("Received from server:", response.decode())
except Exception as e:
    print("Connection error:", e)
