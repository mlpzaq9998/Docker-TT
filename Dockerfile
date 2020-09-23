# build stage
FROM centos:7 as build-stage

# Multi arch build support
FROM alpine as qemu

ARG QEMU_VERSION="v5.1.0-2"

RUN wget https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-aarch64-static && chmod +x qemu-aarch64-static

# production stage
FROM arm64v8/centos:7

MAINTAINER Imagine ZYL

COPY --from=qemu qemu-aarch64-static /usr/bin/

ENV SSH_PASSWORD=111

# Install base tool
RUN yum -y install dstat wget sysstat iputils-ping

#install cronie

RUN yum -y install cronie

#install crontabs

RUN yum -y install crontabs

RUN sed -i '/session    required   pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/crond
RUN echo "*/1 * * * * sh /ttnode-start.sh" >> /var/spool/cron/root

# Install SSH Service
RUN yum install -y openssh-server passwd
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    echo "${SSH_PASSWORD}" | passwd "root" --stdin
	
# Install HAPP
COPY sh/ /sh/
RUN (chmod -R 755 /sh/ )
COPY ttnode/ /root/
RUN sh /sh/ttnode-init.sh && \
    rm -rf /sh/

# Setting DateTime Zone
RUN cp -p /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Start run
ENTRYPOINT [ "/usr/sbin/crond","-i","-n" ]
