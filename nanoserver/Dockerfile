# escape=`

# variants are [nanoserver, sac2016]
ARG VARIANT=nanoserver

# base tag used for the powershell image, ex: nanoserver-1709, nanoserver-1803, etc
ARG POWERSHELL_BASETAG=nanoserver

#================================================

# openjdk has a nanoserver:sac2016 based image, so we'll use it
FROM openjdk:8u131-jdk-nanoserver AS openjdk-sac2016
# We'll also symlink pwsh.exe -> powershell.exe so we can use pwsh throughout
RUN New-Item -ItemType SymbolicLink -Path C:\windows\system32\pwsh.exe -Value (get-command powershell.exe).Source
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

#================================================

# For 1709+ we need to build our own openjdk base
FROM microsoft/powershell:${POWERSHELL_BASETAG} AS openjdk-nanoserver

USER ContainerAdministrator

ENV JAVA_HOME C:\\ojdkbuild
ENV PATH "C:\Windows\system32;C:\Users\ContainerUser\AppData\Local\Microsoft\WindowsApps;C:\Program Files\PowerShell;${JAVA_HOME}\bin"

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# https://github.com/ojdkbuild/ojdkbuild/releases
ENV JAVA_VERSION 8u161
ENV JAVA_OJDKBUILD_VERSION 1.8.0.161-1
ENV JAVA_OJDKBUILD_ZIP java-1.8.0-openjdk-1.8.0.161-1.b14.ojdkbuild.windows.x86_64.zip
ENV JAVA_OJDKBUILD_SHA256 7fcd9909173ed19f4ae6c0bba8b32b1e6bece2d49eb9d87271828be8121fc31b

RUN $url = ('https://github.com/ojdkbuild/ojdkbuild/releases/download/{0}/{1}' -f $env:JAVA_OJDKBUILD_VERSION, $env:JAVA_OJDKBUILD_ZIP); `
	Write-Host ('Downloading {0} ...' -f $url); `
	Invoke-WebRequest -Uri $url -OutFile 'ojdkbuild.zip'; `
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:JAVA_OJDKBUILD_SHA256); `
	if ((Get-FileHash ojdkbuild.zip -Algorithm sha256).Hash -ne $env:JAVA_OJDKBUILD_SHA256) { `
		Write-Host 'FAILED!'; `
		exit 1; `
	}; `
  `
	Write-Host 'Expanding ...'; `
	Expand-Archive ojdkbuild.zip -DestinationPath C:\; `
	`
	Write-Host 'Renaming ...'; `
	Move-Item `
		-Path ('C:\{0}' -f ($env:JAVA_OJDKBUILD_ZIP -Replace '.zip$', '')) `
		-Destination $env:JAVA_HOME `
	; `
	`
	Write-Host 'Verifying install ...'; `
	Write-Host '  java -version'; java -version; `
	Write-Host '  javac -version'; javac -version; `
	`
	Write-Host 'Removing ...'; `
	Remove-Item ojdkbuild.zip -Force; `
	`
	Write-Host 'Complete.';

FROM openjdk-${VARIANT} as minecraft

# TODO: Add Python for mcstatus
# TODO: pip install mcstatus

# Note: 'localhost' can bizarrely resolve to external addresses on some networks
# HEALTHCHECK CMD mcstatus 127.0.0.1 ping

# TODO: Create minecraft user

EXPOSE 25565 25575

ADD https://github.com/itzg/rcon-cli/releases/download/1.3/rcon-cli_windows_amd64.exe /tools/rcon-cli.exe
RUN cmd /c 'setx /M PATH \"C:\tools;%PATH%\"'

COPY minecraft /minecraft

VOLUME ["C:\\data","C:\\mods","C:\\config","C:\\plugins","C:\\users\\minecraft"]

WORKDIR C:\data

ENTRYPOINT [ "pwsh", "-File", "C:\\minecraft\\start.ps1" ]

ENV UID=1000 `
    GID=1000 `
    MOTD="A Minecraft Server Powered by Docker" `
    JVM_XX_OPTS="-XX:+UseG1GC" `
    MEMORY="1G" `
    TYPE=VANILLA`
    VERSION=LATEST `
    FORGEVERSION=RECOMMENDED `
    LEVEL=world `
    PVP=true `
    DIFFICULTY=easy `
    ENABLE_RCON=true `
    RCON_PORT=25575 `
    RCON_PASSWORD=minecraft `
    LEVEL_TYPE=DEFAULT `
    GENERATOR_SETTINGS= `
    WORLD= `
    MODPACK= `
    ONLINE_MODE=TRUE `
    CONSOLE=true

USER ContainerUser