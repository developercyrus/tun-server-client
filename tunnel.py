import os
import select
import socket
import struct
import sys
import fcntl

TUNSETIFF = 0x400454ca
IFF_TUN = 0x0001
IFF_NO_PI = 0x1000

def create_tun(tun_name):
    tun = open('/dev/net/tun', 'r+b', buffering=0)
    ifr = struct.pack('16sH', tun_name.encode(), IFF_TUN | IFF_NO_PI)
    fcntl.ioctl(tun, TUNSETIFF, ifr)
    return tun

def main(local_ip, remote_ip, port):
    tun = create_tun('tun0')
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((local_ip, port))

    while True:
        r, _, _ = select.select([tun, sock], [], [])
        for fd in r:
            if fd is tun:
                data = tun.read(1500)
                sock.sendto(data, (remote_ip, port))
            if fd is sock:
                data, addr = sock.recvfrom(1500)
                tun.write(data)

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <local_ip> <remote_ip> <port>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]))

