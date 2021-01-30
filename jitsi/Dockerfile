FROM ubuntu:20.04

RUN \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y curl wget gpg openjdk-8-jre-headless

RUN wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | apt-key add - 

RUN sh -c "echo 'deb https://download.jitsi.org stable/' \
               > /etc/apt/sources.list.d/jitsi-stable.list"
RUN apt-get update 

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y jitsi-meet-prosody
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y jitsi-meet-turnserver
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y jitsi-meet
