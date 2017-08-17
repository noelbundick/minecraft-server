FROM itzg/minecraft-server

SHELL ["/bin/bash", "-c"]

ENV EULA=TRUE \
    ONLINE_MODE=FALSE \
    SEED=-9363708386013540 \
    VERSION=1.12.1 \
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
    && grep -q "Stopping server" <(tail -f minecraft.out) \
    && rm eula.txt \
    && rm minecraft.out \
    && rm server.properties \
    && rm -r ./logs \
    && cp -r /data /default \
    && chown -R minecraft:minecraft /default

ENV EULA= \
    RCON_PASSWORD=cheesesteakjimmys

COPY customstart.sh /

ENTRYPOINT ["/customstart.sh"]