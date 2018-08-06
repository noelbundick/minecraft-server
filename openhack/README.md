# OpenHack Minecraft

A Minecraft server with some preset customizations

## Running images

### Linux

```bash
docker run -d -p 25565:25565 -e EULA=TRUE openhack/minecraft-server
```

### Windows

```bash
docker run -m 2G -d -p 25565:25565 -e EULA=TRUE openhack/minecraft-server
```

#### Note

The Windows version needs an additional option (`-m 2G`) to run inside a Hyper-V container (ex: on Windows 10) to allow more than the default 1GB memory limit. This option shouldn't be necessary when running as a Windows container on Windows Server.

## Building images

As of 2018-08-03, you will need to enable set `"experimental": "enabled"` in your `.docker/config.json` file to enable `docker manifest` commands

### Linux

Run `build-alpine.sh`

### Windows

Run `build-nanoserver.sh`

## Multi-arch

Run `push-multi-arch.sh`