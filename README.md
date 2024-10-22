sudo docker network create --driver bridge --subnet 172.20.0.0/16 tun_net

sudo docker build --no-cache -t tun-server -f server.Dockerfile .

sudo docker build --no-cache -t tun-client -f client.Dockerfile .


sudo docker run -it \
 --rm \
 --name tun-server \
 --cap-add=NET_ADMIN \
 --privileged \
 --device /dev/net/tun:/dev/net/tun \
 --network tun_net --ip 172.20.0.2 \
 tun-server

 
sudo docker run -it \
 --rm \
 --name tun-client \
 --cap-add=NET_ADMIN \
 --privileged \
 --device /dev/net/tun:/dev/net/tun \
 --network tun_net --ip 172.20.0.3 \
 tun-client
