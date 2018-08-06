# escape=`

# base tag used for the minecraft image, ex: nanoserver-1709, nanoserver-1803, etc
ARG BASETAG=nanoserver

FROM acanthamoeba/minecraft-server:${BASETAG} AS openhack-1.0

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV EULA=TRUE `
    ONLINE_MODE=FALSE `
    SEED=-9363708386013540 `
    VERSION=1.12.2 `
    DIFFICULTY=peaceful `
    GUI=FALSE `
    CONSOLE=FALSE

RUN $minecraft = Start-Process -FilePath 'pwsh' -Args @('-File C:\minecraft\start.ps1') -RedirectStandardOutput minecraft.out -PassThru; `
    Start-Sleep -Seconds 2; `
    while((Select-String -Pattern 'RCON running' -Path C:\data\minecraft.out) -eq $null) { Start-Sleep -Seconds 1 }; `
    rcon-cli --host 127.0.0.1 --port 25575 --password minecraft setworldspawn 555 66 439; `
    rcon-cli --host 127.0.0.1 --port 25575 --password minecraft gamerule doDaylightCycle false; `
    rcon-cli --host 127.0.0.1 --port 25575 --password minecraft time set 6000; `
    rcon-cli --host 127.0.0.1 --port 25575 --password minecraft stop; ` 
    Wait-Process -InputObject $minecraft; `
    rm minecraft\eula.txt; `
    rm minecraft.out; `
    rm minecraft\server.properties; `
    rm -r .\minecraft\logs; `
    cp -r C:\data C:\default;

ENV EULA= `
    RCON_PASSWORD=cheesesteakjimmys

COPY customstart.ps1 C:\minecraft

ENTRYPOINT [ "pwsh", "-File", "C:\\minecraft\\customstart.ps1" ]

FROM openhack-1.0 as openhack-2.0

COPY customstart-2.0.ps1 C:\minecraft\customstart.ps1