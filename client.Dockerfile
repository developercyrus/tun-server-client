# Use a base image with curl
FROM ubuntu:latest

# Install necessary tools
RUN apt update && apt install -y iproute2 curl

# Create a script to setup TUN device and test connection
RUN echo '#!/bin/bash\n\
ip tuntap add dev tun0 mode tun\n\
ip addr add 10.0.0.2/24 dev tun0\n\
ip link set tun0 up\n\
ip route add 10.0.0.1 dev tun0\n\
echo "Waiting for server to be ready..."\n\
sleep 5\n\
echo "Attempting to curl server..."\n\
curl http://10.0.0.1:8080/index.html\n\
' > test_connection.sh && chmod +x test_connection.sh

# Command to run when the container starts
CMD ["./test_connection.sh"]
