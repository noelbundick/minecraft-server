FROM openjdk:8u131-jre-alpine AS itzg

LABEL maintainer "itzg"

RUN apk add -U \
          openssl \
          imagemagick \
          lsof \
          su-exec \
          bash \
          curl iputils wget \
          git \
          jq \
          mysql-client \
          python python-dev py2-pip && \
        rm -rf /var/cache/apk/*

RUN pip install mcstatus

HEALTHCHECK CMD mcstatus localhost ping

RUN addgroup -g 1000 minecraft \
  && adduser -Ss /bin/false -u 1000 -G minecraft -h /home/minecraft minecraft \
  && mkdir /data \
  && mkdir /config \
  && mkdir /mods \
  && mkdir /plugins \
  && chown minecraft:minecraft /data /config /mods /plugins /home/minecraft

EXPOSE 25565 25575

ADD https://github.com/itzg/restify/releases/download/1.0.4/restify_linux_amd64 /usr/local/bin/restify
ADD https://github.com/itzg/rcon-cli/releases/download/1.3/rcon-cli_linux_amd64 /usr/local/bin/rcon-cli
COPY start.sh /start
COPY start-minecraft.sh /start-minecraft
COPY mcadmin.jq /usr/share
RUN chmod +x /usr/local/bin/*

VOLUME ["/data","/mods","/config","/plugins","/home/minecraft"]
COPY server.properties /tmp/server.properties
WORKDIR /data

ENTRYPOINT [ "/start" ]

ENV UID=1000 GID=1000 \
    MOTD="A Minecraft Server Powered by Docker" \
    JVM_XX_OPTS="-XX:+UseG1GC" MEMORY="1G" \
    TYPE=VANILLA VERSION=LATEST FORGEVERSION=RECOMMENDED LEVEL=world PVP=true DIFFICULTY=easy \
    ENABLE_RCON=true RCON_PORT=25575 RCON_PASSWORD=minecraft \
    LEVEL_TYPE=DEFAULT GENERATOR_SETTINGS= WORLD= MODPACK= ONLINE_MODE=TRUE CONSOLE=true


FROM itzg

SHELL ["/bin/bash", "-c"]

ENV EULA=TRUE \
    ONLINE_MODE=FALSE \
    SEED=-9363708386013540 \
    VERSION=1.13 \
    DIFFICULTY=peaceful \
    GUI=FALSE \
    CONSOLE=FALSE

# Note: The 'sh -c' command stops with exit code 143
RUN nohup /start >minecraft.out & 2>&1 \
    && sleep 2s \
    && tail -n +0 -f minecraft.out & 2>&1 \
    && grep -q "RCON running" <(tail -f minecraft.out) \
    && rcon-cli --host 127.0.0.1 --port 25575 --password minecraft setworldspawn 555 66 439 \ 
    && rcon-cli --host 127.0.0.1 --port 25575 --password minecraft gamerule doDaylightCycle false \
    && rcon-cli --host 127.0.0.1 --port 25575 --password minecraft time set 6000 \
    && rcon-cli --host 127.0.0.1 --port 25575 --password minecraft stop \
    && while pidof java > /dev/null; do sleep 1; done; echo "Server stopped" \
    && rm eula.txt \
    && rm minecraft.out \
    && rm server.properties \
    && rm -r ./logs \
    && cp -r /data /default \
    && rm -rf /data/*

ENV EULA= \
    RCON_PASSWORD=cheesesteakjimmys

COPY customstart.sh /

ENTRYPOINT ["/customstart.sh"]