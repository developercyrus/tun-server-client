# Use a base image with Python
FROM python:3.9-slim

# Install necessary tools
RUN apt-get update && apt-get install -y iproute2 curl

WORKDIR /public_html
COPY index.html /public_html

# Create a script to setup TUN device and start the server
RUN echo '#!/bin/bash\n\
ip tuntap add dev tun0 mode tun\n\
ip addr add 10.0.0.1/24 dev tun0\n\
ip link set tun0 up\n\
ip route\n\
python3 -m http.server --bind 10.0.0.1 8080 --directory /public_html\n\
' > start_server.sh && chmod +x start_server.sh

# Command to run when the container starts
CMD ["./start_server.sh"]
