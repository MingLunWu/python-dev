FROM centos:7

USER root

RUN yum -y install epel-release
RUN yum -y update

RUN yum -y groupinstall "Development Tools"
RUN yum -y install openssl-devel bzip2-devel libffi-devel xz-devel

RUN yum -y install wget yq jq

# Python 3.8.6
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz
RUN tar xvf Python-3.8.6.tgz
WORKDIR /tmp/Python-3.8.6
RUN ./configure --enable-optimizations
RUN make altinstall

# Python 3.7.5
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tgz
RUN tar xvf Python-3.7.5.tgz
WORKDIR /tmp/Python-3.7.5
RUN ./configure --enable-optimizations
RUN make altinstall

# Python 3.6.6
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz
RUN tar xvf Python-3.6.6.tgz
WORKDIR /tmp/Python-3.6.6
RUN ./configure --enable-optimizations
RUN make altinstall

WORKDIR /tmp
RUN rm -rf Python-3.6.6/ Python-3.7.5/ Python-3.8.6/ Python-3.6.6.tgz Python-3.7.5.tgz Python-3.8.6.tgz
WORKDIR /

# Pip package
RUN pip3.8 install poetry && poetry config virtualenvs.in-project true

CMD ["sleep", "infinity"]