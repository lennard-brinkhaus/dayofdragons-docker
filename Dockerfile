FROM debian:10-slim
LABEL maintainer="Alphyron <admin@dragon-labs.de>"

ENV DEBIAN_FRONTEND noninteractive
ENV SERVER_NAME DayOfDragon-Server by Alphyron

EXPOSE 80 443
EXPOSE 27015/tcp 27015/udp 27016/tcp 27016/udp
EXPOSE 7777/udp 7778/udp
EXPOSE 4380/udp

RUN apt-get update \
    && apt-get upgrade \
    && echo "deb http://mirrors.linode.com/debian stretch main non-free" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.linode.com/debian stretch main non-free" >> /etc/apt/sources.list \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y lib32stdc++6 lib32gcc1 wget \
    && apt-get clean \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

# setup steam user
RUN useradd -m steam
WORKDIR /home/steam
USER steam

# download steamcmd
RUN mkdir steamcmd && cd steamcmd && \
    wget -O - "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# start steamcmd to force it to update itself
RUN ./steamcmd/steamcmd.sh +quit && \
    mkdir -pv /home/steam/.steam/sdk32/ && \
    ln -s /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so

# Install the Game
RUN ./steamcmd/steamcmd.sh +login anonymous +app_update 1088320 +quit 
COPY --chown=steam assets/entrypoint.sh ./entrypoint.sh

RUN chmod +x /home/steam/Steam/steamapps/common/dayofdragons_server/Dragons/Binaries/Linux/DragonsServer-Linux-Shipping
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]