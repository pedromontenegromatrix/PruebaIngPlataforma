#!/bin/bash

sudo yum upgrade -y
sudo yum update -y

sudo yum update kernel -y
sudo yum update kernel-tools -y
sudo yum update systemd-libs -y
sudo yum update systemd -y
sudo yum update systemd-sysv -y
sudo yum update gnupg2 -y
sudo yum update openssl-libs -y
sudo yum update openssl -y
sudo yum update microcode_ctl -y
sudo yum update zlib -y
sudo yum update libxml2 -y
sudo yum update libxml2-python -y
sudo yum install java-1.8.0 -y

sudo yum update vim-common -y
sudo yum update vim-data -y
sudo yum update vim-enhanced -y
sudo yum update vim-filesystem -y
sudo yum update vim-minimal -y

sudo yum update dbus -y
sudo yum update dbus-libs -y

sudo yum update glibc -y
sudo yum update glibc-locale-source -y
sudo yum update glibc-all-langpacks -y
sudo yum update glibc-common -y
sudo yum update glibc-minimal-langpack -y
sudo yum update libcrypt -y
sudo yum update libtiff -y
sudo yum install jq -y

sudo yum update openldap -y
sudo yum update libwebp -y
sudo yum update screen -y
# sudo yum update libxml2 -y
# sudo yum update libxml2-python -y

sudo yum install telnet -y


wget https://archive.apache.org/dist/kafka/2.6.2/kafka_2.12-2.6.2.tgz
tar -xzf kafka_2.12-2.6.2.tgz

curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --short --client

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

sudo dnf upgrade --releasever=2023.4.20240528 -y
sudo grubby --set-default /boot/vmlinuz-6.1.91-99.172.amzn2023.x86_64
sudo systemctl reboot
