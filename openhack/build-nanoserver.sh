#!/bin/sh

docker build -t openhack/minecraft-server:1.0-nanoserver-1803 --build-arg BASETAG=nanoserver-1803 --target openhack-1.0 ./nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver-1803
docker build -t openhack/minecraft-server:1.0-nanoserver-1709 --build-arg BASETAG=nanoserver-1709 --target openhack-1.0 ./nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver-1709
docker build -t openhack/minecraft-server:1.0-nanoserver-sac2016 --build-arg BASETAG=nanoserver-sac2016 --target openhack-1.0 ./nanoserver/
docker push openhack/minecraft-server:1.0-nanoserver-sac2016

docker build -t openhack/minecraft-server:2.0-nanoserver-1803 --build-arg BASETAG=nanoserver-1803 --target openhack-2.0 ./nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver-1803
docker build -t openhack/minecraft-server:2.0-nanoserver-1709 --build-arg BASETAG=nanoserver-1709 --target openhack-2.0 ./nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver-1709
docker build -t openhack/minecraft-server:2.0-nanoserver-sac2016 --build-arg BASETAG=nanoserver-sac2016 --target openhack-2.0 ./nanoserver/
docker push openhack/minecraft-server:2.0-nanoserver-sac2016