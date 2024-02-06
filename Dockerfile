FROM centos:7 as base_stage

USER root

RUN yum -y remove git git-*

RUN yum -y install epel-release && \
    yum -y update && \
    yum -y groupinstall "Development Tools" && \
    yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm && \
    yum -y install openssl-devel openssl11 openssl11-devel bzip2-devel libffi-devel xz-devel sqlite-devel wget yq jq git && \
    yum -y install postgresql-devel

FROM base_stage as python_stage

# Python 3.11.5
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.11.5/Python-3.11.5.tgz && \
    tar xvf Python-3.11.5.tgz
WORKDIR /tmp/Python-3.11.5
RUN export CFLAGS=$(pkg-config --cflags openssl11) && \
    export LDFLAGS=$(pkg-config --libs openssl11) && \
    ./configure && \
    make altinstall

# Python 3.9.18
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.8.6/Python-3.9.18.tgz && \
    tar xvf Python-3.9.18.tgz
WORKDIR /tmp/Python-3.9.18
RUN ./configure --enable-optimizations && \
    make altinstall

# Python 3.8.6
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.8.6/Python-3.8.6.tgz && \
    tar xvf Python-3.8.6.tgz
WORKDIR /tmp/Python-3.8.6
RUN ./configure --enable-optimizations && \
    make altinstall

# Python 3.7.5
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.7.5/Python-3.7.5.tgz && \ 
    tar xvf Python-3.7.5.tgz
WORKDIR /tmp/Python-3.7.5
RUN ./configure --enable-optimizations && \
    make altinstall

WORKDIR /tmp
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.7 get-pip.py && \
    python3.8 get-pip.py && \
    python3.9 get-pip.py && \
    python3.11 get-pip.py

# VSCode Container
FROM python_stage as tools_stage
WORKDIR /tmp
RUN wget https://update.code.visualstudio.com/commit:441438abd1ac652551dbe4d408dfcec8a499b8bf/server-linux-x64/stable && \
    tar xvf stable && \
    mkdir -p /root/.vscode-server/bin/ && \
    cp -r vscode-server-linux-x64 /root/.vscode-server/bin/441438abd1ac652551dbe4d408dfcec8a499b8bf && \
    rm -rf stable vscode-server-linux-x64/

# Oh-my-zsh
RUN yum -y install zsh && \
    chsh -s /usr/bin/zsh root && \
    su && \
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

COPY .zshrc /root/.zshrc
RUN git clone https://github.com/bhilburn/powerlevel9k.git /root/.oh-my-zsh/custom/themes/powerlevel9k && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Pip package
RUN pip3.11 install --no-build-isolation docker-compose && \
    pip3.9 install docker-compose && \
    pip3.8 install docker-compose && \
    pip3.7 install docker-compose

# Install docker
RUN yum install -y yum-utils docker && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
# GCloud SDK
WORKDIR /tmp
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-462.0.1-linux-x86_64.tar.gz && \
    tar -xf google-cloud-cli-462.0.1-linux-x86_64.tar.gz && \
    /bin/zsh /tmp/google-cloud-sdk/install.sh --quiet --rc-path /root/.zshrc && \
    /bin/zsh /tmp/google-cloud-sdk/install.sh --quiet --rc-path /root/.bashrc

WORKDIR /root
CMD ["sleep", "infinity"]
