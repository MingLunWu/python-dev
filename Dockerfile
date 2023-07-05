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

# VSCode Container
WORKDIR /tmp
RUN wget https://update.code.visualstudio.com/commit:441438abd1ac652551dbe4d408dfcec8a499b8bf/server-linux-x64/stable
RUN tar xvf stable
RUN mkdir -p /root/.vscode-server/bin/
RUN cp -r vscode-server-linux-x64 /root/.vscode-server/bin/441438abd1ac652551dbe4d408dfcec8a499b8bf
RUN rm -rf stable vscode-server-linux-x64/

# Oh-my-zsh
RUN yum -y install zsh
RUN chsh -s /usr/bin/zsh root
RUN su
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
COPY .zshrc /root/.zshrc
RUN git clone https://github.com/bhilburn/powerlevel9k.git /root/.oh-my-zsh/custom/themes/powerlevel9k
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
WORKDIR /root

# Pip package
RUN pip3.8 install poetry && poetry config virtualenvs.in-project true

CMD ["sleep", "infinity"]