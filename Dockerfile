FROM redhat/ubi8:8.5 AS base_stage

RUN yum update -y && \
    yum groupinstall -y "Development Tools" && \
    yum install -y wget bzip2 make gcc zlib-devel openssl-devel libffi-devel

FROM base_stage AS python_stage

# Python 3.11.7
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.11.7/Python-3.11.7.tgz && \
    tar xvf Python-3.11.7.tgz
WORKDIR /tmp/Python-3.11.7
RUN export CFLAGS=$(pkg-config --cflags openssl11) && \
    export LDFLAGS=$(pkg-config --libs openssl11) && \
    ./configure && \
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
    python3.11 get-pip.py

# VSCode Container
# FROM python_stage as tools_stage
FROM centos:8 AS tmp_stage
USER root
WORKDIR /tmp
RUN wget https://update.code.visualstudio.com/commit:441438abd1ac652551dbe4d408dfcec8a499b8bf/server-linux-x64/stable && \
    tar xvf stable && \
    mkdir -p /root/.vscode-server/bin/ && \
    cp -r vscode-server-linux-x64 /root/.vscode-server/bin/441438abd1ac652551dbe4d408dfcec8a499b8bf && \
    rm -rf stable vscode-server-linux-x64/ && \
    wget https://update.code.visualstudio.com/commit:fee1edb8d6d72a0ddff41e5f71a671c23ed924b9/server-linux-x64/stable && \
    tar xvf stable && \
    mkdir -p /root/.vscode-server/bin/ && \
    cp -r vscode-server-linux-x64 /root/.vscode-server/bin/fee1edb8d6d72a0ddff41e5f71a671c23ed924b9 && \
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
