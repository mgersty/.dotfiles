FROM debian:12-slim

RUN apt update -y && apt upgrade

RUN apt install -y --no-install-recommends sudo ca-certificates build-essential apt-transport-https net-tools tcpdump tshark termshark gnupg gzip curl unzip wget man  vim

RUN setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap
