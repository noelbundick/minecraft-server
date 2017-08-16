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

## Note on connecting from localhost

At the time of this writing, you can't use localhost to access published ports, which means that your server will start correctly, but you won't be able to connect on localhost. You'll need to use the container IP instead.

```powershell
# Get the ID/name of your container
docker ps

# Get the IP of your container
docker inspect --format '{{ range .NetworkSettings.Networks }}{{.IPAddress}}{{end}}' <container_name_here>
```