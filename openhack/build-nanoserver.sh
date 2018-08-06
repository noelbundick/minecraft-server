#!/bin/sh

docker build -m 2GB -t openhack/minecraft-server:1.0-nanoserver-1803 --build-arg BASETAG=nanoserver-1803 --target openhack-1.0 ./nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver-1803

docker build -m 2GB -t openhack/minecraft-server:1.0-nanoserver-1709 --build-arg BASETAG=nanoserver-1709 --target openhack-1.0 ./nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver-1709

docker build -m 2GB -t openhack/minecraft-server:1.0-nanoserver-sac2016 --build-arg BASETAG=nanoserver-sac2016 --target openhack-1.0 ./nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver-sac2016

docker manifest create openhack/minecraft-server:1.0-nanoserver openhack/minecraft-server:1.0-nanoserver-1803 openhack/minecraft-server:1.0-nanoserver-1709 openhack/minecraft-server:1.0-nanoserver-sac2016
docker manifest push openhack/minecraft-server:1.0-nanoserver

docker build -m 2GB -t openhack/minecraft-server:2.0-nanoserver-1803 --build-arg BASETAG=nanoserver-1803 --target openhack-2.0 ./nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver-1803

docker build -m 2GB -t openhack/minecraft-server:2.0-nanoserver-1709 --build-arg BASETAG=nanoserver-1709 --target openhack-2.0 ./nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver-1709

docker build -m 2GB -t openhack/minecraft-server:2.0-nanoserver-sac2016 --build-arg BASETAG=nanoserver-sac2016 --target openhack-2.0 ./nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver-sac2016

docker manifest create openhack/minecraft-server:2.0-nanoserver openhack/minecraft-server:2.0-nanoserver-1803 openhack/minecraft-server:2.0-nanoserver-1709 openhack/minecraft-server:2.0-nanoserver-sac2016
docker manifest push openhack/minecraft-server:2.0-nanoserver