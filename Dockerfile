FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v4.0.0%2Bbalena2/qemu-4.0.0.balena2-aarch64.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm64v8/ubuntu

# Add QEMU
COPY --from=qemu qemu-aarch64-static /usr/bin

MAINTAINER Imagine ZYL

# Install base tool
RUN apt update
RUN apt -y install dstat wget sysstat iputils-ping tzdata

#install cronie

RUN apt -y install cron

RUN sed -i '/session    required   pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron
RUN echo "*/1 * * * * sh /ttnode-start.sh" >> /var/spool/cron/root
	
# Install TT
COPY sh/* ./sh/
RUN (chmod -R 755 /sh/ )
COPY ttnode/* ./root/
RUN (chmod -R 755 /root/ )
RUN sh /sh/ttnode-init.sh && \
    rm -rf /sh/

# Setting DateTime Zone
RUN cp -p /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Start run
ENTRYPOINT [ "/usr/sbin/cron","-i","-n" ]
