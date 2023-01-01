FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install rsync screen net-tools openssh-server -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh

EXPOSE 22

WORKDIR /usr/src/app

COPY . .
RUN chmod +x start.sh

CMD ["/usr/src/app/start.sh"]