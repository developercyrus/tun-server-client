# Use a base image with Python
FROM python:3.9-slim

# Install necessary tools
RUN apt-get update && apt-get install -y iproute2 curl iptables bsdmainutils procps net-tools iputils-ping tcpdump

WORKDIR /public_html
COPY index.html /public_html
COPY tunnel.py /

# Create a script to setup TUN device and start the server
RUN echo '#!/bin/bash\n\
ip tuntap add dev tun0 mode tun\n\
ip addr add 10.0.0.1/24 dev tun0\n\
ip link set tun0 up\n\
sysctl net.ipv4.ip_forward=1\n\
iptables -t nat -A POSTROUTING -o eth0+ -s 10.0.0.0/24 -j MASQUERADE\n\
iptables -A FORWARD -i tun0 -o eth0+ -j ACCEPT\n\
iptables -A FORWARD -i eth0+ -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT\n\
cat /proc/sys/net/ipv4/ip_forward\n\
iptables -t nat -L -n -v\n\
iptables -L -n -v\n\
route -n\n\
ip route | column -t\n\
ip addr show\n\
python3 /tunnel.py 172.20.0.2 172.20.0.3 5000 &\n\
ping -c 4 8.8.8.8\n\
#tcpdump -i tun0\n\
python3 -m http.server --bind 10.0.0.1 8080 --directory /public_html\n\
' > /start_server.sh && chmod +x /start_server.sh

# Command to run when the container starts
CMD ["/start_server.sh"]
