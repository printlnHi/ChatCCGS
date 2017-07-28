import socket

def Main():
    host = '127.0.0.1'
    port = 5000

    s = socket.socket()
    s.bind((host, port))
    
    s.listen(1)
    c, addr = s.accept()
    print("Connection from: " + str(addr))
    while True:
        data = c.recv(1024)
        dataArray = bytearray(data)
        dataString = data.decode('utf-8')
        if not dataString:
            break
        print("From connected user:",dataString,"data =",data,"dataArray=",dataArray)
        dataString = dataString.upper()
        print("Sending: " + dataString)
        c.send(dataString.encode('utf-8'))
    c.close()

if __name__ == '__main__':
    Main()
        
