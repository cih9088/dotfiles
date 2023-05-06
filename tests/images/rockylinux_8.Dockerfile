from rockylinux:8

RUN dnf install -y sudo git make passwd perl gcc gcc-c++ python3 python3-devel python3-pip \
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN passwd -d root
RUN useradd -m -s /bin/bash docker && passwd -d docker && usermod docker -G wheel
USER docker
