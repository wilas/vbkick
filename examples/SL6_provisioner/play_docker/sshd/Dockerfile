# sshd
#
# VERSION               0.0.1
# BASE ON               http://docs.docker.io/examples/running_ssh_service/

FROM    centos
MAINTAINER Kamil Wilas - wilas.pl

# Install
RUN yum -y install openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:rootme' | chpasswd
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N "" -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N "" -t dsa

EXPOSE 22

# without extra option: "debug1: Exit status 254"
CMD  /usr/sbin/sshd -D -o UsePAM=no
