from rockylinux:9

RUN dnf install -y sudo git make passwd && dnf clean all && rm -rf /var/cache/dnf

RUN passwd -d root
RUN useradd -m -s /bin/bash docker && passwd -d docker && usermod docker -G wheel
USER docker
