#!/bin/bash

set -ex

apt-get update

LINUX_PACKAGES=(
    python3-pip
    zsh
    ssh
    vim
    figlet
    nscd
    less
    curl
    wget
    iputils-ping
    git
    rsync
    screen
    tmux
    ipmitool
    gnupg
    gnupg2
    dnsutils
    net-tools
    libffi-dev # https://stackoverflow.com/a/58396708
    sudo
    libssl-dev # https://askubuntu.com/a/797352
)
apt-get install -y "${LINUX_PACKAGES[@]}"

PYTHON_PACKAGES=(
    ipython
    jira
    plumbum
    pytz
    pytest
    pylint
    pycodestyle
)
for package_name in "${PYTHON_PACKAGES[@]}"; do
    pip3 install "$package_name"
done

ln -s "$(which python3)" /usr/bin/python

cd /root
chsh -s /usr/bin/zsh
