import websocket
import sys

ws_server = sys.argv[1]

from websocket import create_connection
ws = create_connection(ws_server)
print("Sending 'Hello, World'...")
ws.send("Hello, World")
print("Sent")
print("Receiving...")
result = ws.recv()
print("Received '%s'" % result)
ws.close()