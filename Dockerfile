FROM centos:centos7
MAINTAINER Imagine ZYL


ENV SSH_PASSWORD=111


# Install base tool
RUN yum -y install dstat wget sysstat iputils-ping qemu-user-static

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
