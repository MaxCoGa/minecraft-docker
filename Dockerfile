FROM ubuntu:24.04

RUN apt update
RUN apt-get install -y --no-install-recommends wget ca-certificates jq
RUN apt install wget curl -y
RUN apt install openjdk-17-jre-headless -y
RUN apt install tmux -y

VOLUME [ "/mcdata" ]

WORKDIR /mcdata

WORKDIR /mcdata/ngrok
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /mcdata/ngrok/ngrok-v3-stable-linux-amd64.tgz 
RUN tar xvzf /mcdata/ngrok/ngrok-v3-stable-linux-amd64.tgz -C /mcdata/ngrok/

WORKDIR /mcdata/server
RUN wget https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/435/downloads/paper-1.20.4-435.jar -O /mcdata/server/server.jar

WORKDIR /mcdata
# RUN  java -Xmx1024M -Xms1024M -jar server.jar nogui 