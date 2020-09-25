FROM alpine AS qemu

#QEMU Download
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v4.0.0%2Bbalena2/qemu-4.0.0.balena2-aarch64.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm64v8/centos:7 AS build
RUN yum -y groupinstall "Development Tools"
RUN yum -y install glibc-static libstdc++-static
RUN wget -P /tmp http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-5.4.0/gcc-5.4.0.tar.bz2
RUN tar jxvf /tmp/gcc-5.4.0.tar.bz2
RUN cd /tmp/gcc-5.4.0
RUN ./contrib/download_prerequisits
RUN mkdir build
RUN cd build
RUN ../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib
RUN make && make install

FROM arm64v8/centos:7

# Add QEMU
COPY --from=qemu qemu-aarch64-static /usr/bin
COPY --from=build /usr/local/lib64/libstdc++.so.6.0.21 /lib64
RUN rm -rf libstdc++.so.6 libstdc++.so.6.0.19
RUN ln -s libstdc++.so.6.0.21 libstdc++.so.6

MAINTAINER Imagine ZYL

ENV SSH_PASSWORD=111

# Install base tool
RUN yum -y install dstat wget sysstat iputils

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
	
# Install TT
COPY sh/* ./sh/
RUN (chmod -R 755 /sh/ )
COPY ttnode/* ./root/
RUN (chmod -R 755 /root/ )
RUN sh /sh/ttnode-init.sh && \
    rm -rf /sh/

# Setting DateTime Zone
RUN cp -p /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN strings /lib64/libstdc++.so.6 | grep GLIBC

# Start run
ENTRYPOINT [ "/usr/sbin/crond","-i","-n" ]
