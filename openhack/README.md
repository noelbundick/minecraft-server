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

The Windows version needs an additional option (`-m 2G`) to run inside a Hyper-V container (ex: on Windows 10) to allow more than the default 1GB memory limit. This option shouldn't be necessary when running as a Windows container on Windows Server 2016.

Windows Containers currently don't support port forwarding on localhost. If you want to connect to a container running locally, you'll need the container IP. You can get this by running the following command: `docker inspect --format '{{ range .NetworkSettings.Networks }}{{.IPAddress}}{{end}}' <containerId>`

## Building images

### Linux

Run `build-alpine.sh`

### Windows

Run `build-nanoserver.sh`

## Multi-arch

Run `push-multi-arch.sh`

These are currently being built using [manifest-tool](https://github.com/estesp/manifest-tool) until the [`docker manifest`](https://github.com/docker/cli/pull/138) pull request makes it through to general release