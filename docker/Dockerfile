FROM ubuntu:trusty

RUN apt-get update && apt-get install -y sudo

# Required by all benchmarks
RUN apt-get install -y git apt-utils

# block_storage_workload, fio
RUN apt-get install -y libaio-dev libaio1 bc zlib1g-dev autoconf libtool build-essential

# cassandra_ycsb, cassandra_stress
RUN apt-get install -y software-properties-common

# SSH
RUN apt-get install -y ssh
RUN mkdir /var/run/sshd ;\
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd ;\
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config ;\
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config ;\
    echo "UseDNS no" | tee -a /etc/ssh/sshd_config ;\
    echo "MaxSessions 1000" | tee -a /etc/ssh/sshd_config

# Removing apt lock file
RUN sudo rm /var/lib/apt/lists/lock -vf
