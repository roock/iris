FROM gitpod/workspace-full
# FROM gitpod/workspace-base

# Install custom tools, runtime, etc.
#RUN brew install fzf

RUN sudo apt install gnupg2 && \
    wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && \
    sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb && \
    rm percona-release_latest.$(lsb_release -sc)_all.deb && \
    sudo apt update && \
    sudo apt install percona-server-server-5.7 && \
    sudo rm -rf /var/lib/apt/lists/*

