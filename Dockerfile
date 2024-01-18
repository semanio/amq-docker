FROM fedora:latest
ENV container docker
RUN yum -y update; yum clean all
RUN yum -y install systemd; yum clean all;
RUN yum install -y java-11-openjdk-devel which systemd net-tools unzip tar hostname openssh-server sudo openssh-clients && yum clean all
# enable no pass and speed up authentication
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/;s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

# enabling sudo group
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
# enabling sudo over ssh
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

ENV JAVA_HOME /usr/lib/jvm/jre

# add a user for the application, with sudo permissions
RUN useradd -m activemq ; echo activemq: | chpasswd ; usermod -a -G wheel activemq

# command line goodies
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /etc/profile
RUN echo "alias ll='ls -l --color=auto'" >> /etc/profile
RUN echo "alias grep='grep --color=auto'" >> /etc/profile


WORKDIR /home/activemq

# TODO go back to a CURL option? vs copying in a downloaded file
COPY apache-activemq-5.17.6-bin.tar.gz /home/activemq/apache-mq.tar.gz
RUN chown -R activemq:activemq apache-mq.tar.gz

RUN tar -xf apache-mq.tar.gz
RUN rm apache-mq.tar.gz
RUN chown -R activemq:activemq apache-activemq-5.17.6

WORKDIR /home/activemq/apache-activemq-5.17.6/conf

WORKDIR /home/activemq/apache-activemq-5.17.6/bin
RUN chmod u+x ./activemq

WORKDIR /home/activemq/apache-activemq-5.17.6/

# ensure we have a log file to tail
RUN mkdir -p data/
RUN echo >> data/activemq.log
EXPOSE 22 1099 61616 8161 5672 61613 1883 61614

WORKDIR /home/activemq/apache-activemq-5.17.6/conf
RUN rm -f startup.sh

COPY activemq-cluster-config.sh /home/activemq/apache-activemq-5.17.6/conf/startup.sh
COPY jetty.xml /home/activemq/apache-activemq-5.17.6/conf/jetty.xml

RUN chown -R activemq:activemq startup.sh
RUN chown -R activemq:activemq jetty.xml

RUN chmod u+x ./startup.sh

USER activemq

# TODO get this working again
# CMD  /home/activemq/apache-activemq-5.17.6/conf/startup.sh


ENTRYPOINT ["tail", "-f", "/dev/null"]