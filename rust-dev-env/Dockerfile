From debian:stable

RUN \
  apt-get update && \
  apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install curl 

RUN \
cd /tmp && \
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz && \
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz.sha256sum && \
sha256sum --check nvim-linux64.tar.gz.sha256sum  && \
tar -C /opt -xf nvim-linux64.tar.gz 

ENV PATH=$PATH:/opt/nvim-linux64/bin

RUN useradd --create-home --skel /etc/skel --shell /bin/bash  micki

USER micki
