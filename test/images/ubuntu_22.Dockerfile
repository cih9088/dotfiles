from ubuntu:22.04

# Workaround https://unix.stackexchange.com/questions/2544/how-to-work-around-release-file-expired-problem-on-a-local-mirror
RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | \
      cat > /etc/apt/apt.conf.d/10no--check-valid-until
RUN apt update && apt install -y git make curl gcc g++ bsdmainutils sudo python3-dev python3-pip tar
