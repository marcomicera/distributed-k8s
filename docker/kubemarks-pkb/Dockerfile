FROM ubuntu:bionic

# Non-interactive shell
ARG DEBIAN_FRONTEND=noninteractive

# Dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y sudo
RUN sed -e '/DPkg::Pre-Install-Pkgs/s/^/\/\//g' -i /etc/apt/apt.conf.d/70debconf
RUN apt-get install -y python python2.7
RUN apt-get install -y python-pip
RUN pip install --upgrade pip
RUN pip install pandas
RUN pip install numpy
RUN apt-get install -y lsb-release
RUN apt-get install -y git
RUN apt-get install -y cpio
RUN mkdir -vp /opt/pkb
RUN apt-get install -y wget
RUN apt-get install -y build-essential
RUN apt-get install -y libtool
RUN apt-get install -y autoconf
RUN apt-get install -y automake
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y libaio-dev
RUN apt-get install -y libaio1
RUN apt-get install -y bc
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y software-properties-common
RUN apt-get install -y iputils-ping

# MongoDB
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb-community-edition-using-deb-packages
RUN apt-get install gnupg
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
RUN apt-get update
RUN apt-get install -y mongodb-org

# SSH
RUN apt-get install -y ssh
RUN mkdir -v /var/run/sshd ;\
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd ;\
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config ;\
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config ;\
    echo "UseDNS no" | tee -a /etc/ssh/sshd_config ;\
    echo "MaxSessions 1000" | tee -a /etc/ssh/sshd_config

# Clean up APT when done.
RUN apt-get clean
# RUN rm -rvf /var/lib/apt/lists/*
RUN rm -rvf /tmp/*
RUN rm -rvf /var/tmp/*
