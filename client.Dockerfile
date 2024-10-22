

# Use a base image with curl
FROM ubuntu:latest

# Install necessary tools
RUN apt update && apt install -y iproute2 curl iputils-ping bsdmainutils python3 net-tools traceroute

COPY tunnel.py /

# Create a script to setup TUN device and test connection
RUN echo '#!/bin/bash\n\
ip tuntap add dev tun0 mode tun\n\
ip addr add 10.0.0.2/24 dev tun0\n\
ip link set tun0 up\n\
ping -c 4 8.8.8.8\n\
#start: must delete first, and then add route
ip route del default via 172.20.0.1\n\
ip route add default via 10.0.0.1\n\
#end: must delete first, and then add route
ip route | column -t\n\
ip addr show\n\
python3 /tunnel.py 172.20.0.3 172.20.0.2 5000 &\n\
ping -c 4 172.20.0.2\n\
ping -c 4 10.0.0.1\n\
ping -c 4 8.8.8.8\n\
traceroute 8.8.8.8\n\
echo "Waiting for server to be ready..."\n\
sleep 5\n\
echo "Attempting to curl server..."\n\
curl -v --connect-timeout 10 http://10.0.0.1:8080/\n\
' > /test_connection.sh && chmod +x /test_connection.sh

# Command to run when the container starts
CMD ["/test_connection.sh"]
