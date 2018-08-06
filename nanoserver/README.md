# minecraft-server:nanoserver

This is a port of itzg's excellent [minecraft-server](https://hub.docker.com/r/itzg/minecraft-server/), based on a Windows Nano Server image

Currently, only basic vanilla functionality is supported

## Example usage

```powershell
# Build the image
docker build -m 2GB -t minecraft-server:nanoserver .

# Run Minecraft
docker run -d --rm -m 2GB -p 25565:25565 -p 25575:25575 -e EULA=TRUE -v c:/temp/minecraftdata:c:/data minecraft-server:nanoserver
```

## Development

As of 2018-08-03, you will need to enable set `"experimental": "enabled"` in your `.docker/config.json` file to enable `docker manifest` commands

```powershell
# Build images for each OS version
docker build -t acanthamoeba/minecraft-server:nanoserver-1803 --build-arg POWERSHELL_BASETAG=nanoserver-1803 --target minecraft .
docker build -t acanthamoeba/minecraft-server:nanoserver-1709 --build-arg POWERSHELL_BASETAG=nanoserver-1709 --target minecraft .
docker build -t acanthamoeba/minecraft-server:nanoserver-sac2016 --build-arg VARIANT=sac2016 --target minecraft .

# Create a `nanoserver` manifest that points to the various OS versions
docker manifest create minecraft-server acanthamoeba/minecraft-server:nanoserver-1803 acanthamoeba/minecraft-server:nanoserver-1709 acanthamoeba/minecraft-server:nanoserver-sac2016
docker manifest push acanthamoeba/minecraft-server:nanoserver
```