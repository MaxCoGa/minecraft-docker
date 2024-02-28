FROM ubuntu:24.04

RUN apt update
RUN apt-get install -y --no-install-recommends wget ca-certificates jq
RUN apt install wget curl ssh -y
RUN apt install openjdk-17-jre-headless -y
RUN apt install tmux -y

VOLUME [ "/mcdata" ]

WORKDIR /mcdata

WORKDIR /mcdata/server
RUN wget https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/435/downloads/paper-1.20.4-435.jar -O /mcdata/server/server.jar

WORKDIR /mcdata/server/plugin
RUN wget https://github.com/minekube/connect-java/releases/download/latest/connect-spigot.jar
RUN wget https://github.com/NEZNAMY/TAB/releases/download/4.1.2/TAB.v4.1.2.jar

WORKDIR /mcdata
COPY run.sh /mcdata/run.sh
COPY config.yml /mcdata/config.yml
# RUN  java -Xmx1024M -Xms1024M -jar server.jar nogui 