from ubuntu:22.04

# Workaround https://unix.stackexchange.com/questions/2544/how-to-work-around-release-file-expired-problem-on-a-local-mirror
RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | \
      cat > /etc/apt/apt.conf.d/10no--check-valid-until
RUN apt update \
  && apt install -y --no-install-recommends sudo git make passwd curl ca-certificates gcc g++ python3 python3-dev python3-pip \
  && apt-get autoremove -y \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

RUN passwd -d root
RUN useradd -m -s /bin/bash docker && passwd -d docker && usermod docker -G sudo
USER docker
