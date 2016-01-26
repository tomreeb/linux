#!/bin/sh
#
# CentOS 7 VPS Setup script
#
# By: Tom Reeb
# 11-11-15
#
# Instructions: Run locally as root when you first log in
#
# Steps not included:
# 1) Change root passwd
# 2) install public ssh key from laptop
# 3) Enalbe Fail2ban module for ssh
#
# Future considerations:
# - Automate ssh key installation
# * Ask about configuring firewall ports

echo "yosup? I am a script that will help configure your new VPS!"
echo "This server is running " cat /etc/redhat-release
echo "First I am going to ask you a couple of questions"
#read -p "Enter the IP Address of the VPS: " -r vpsip
read -p "First things first, let's reset your root password "
passwd
echo "Cool, that's done"
echo ""
read -p "Paste in your ssh pub key: " -r pubkey
read -p "Enter the Hostname of the VPS: " -r vpshostname
read -p "Enter the Server Admin account name: " -r serveradminUser
read -s -p "Enter the Password for $serveradminUser user: " -r serveradminPasswd
echo ""
echo "Ok I go do things now, brb"

# Set hostname
hostnamectl set-hostname $vpshostname

# Add server admin user
useradd $serveradminUser
echo $serveradminPassword | passwd $serveradminUser --stdin > /dev/null 2>&1

echo "$serveradminUser ALL=(ALL) ALL" >> /etc/sudoers

mkdir /home/$serveradminUser/.ssh/
chmod 700 /home/$serveradminUser/.ssh/
touch /home/$serveradminUser/.ssh/authorized_keys
echo $pubkey > /home/$serveradminUser/.ssh/authorized_keys
chmod 600 /home/$serveradminUser/.ssh/authorized_keys
chown -R $serveradminUser:$serveradminUser /home/$serveradminUser/

# Install EPEL

rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm > /dev/null 2>&1
rpm -iv http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm > /dev/null 2>&1

# Update System
yum -y update > /dev/null 2>&1

# Install necessary packages
yum -y install python-pip htop tmux nano fail2ban > /dev/null 2>&1
pip install --upgrade pip > /dev/null 2>&1
pip install speedtest-cli > /dev/null 2>&1

# Enable Firewalld
systemctl enable firewalld.service > /dev/null 2>&1
systemctl start firewalld.service > /dev/null 2>&1

# Set Up DNS
echo "
DNS1=8.8.8.8
DNS2=8.8.4.4
DOMAIN=reeb.me
" >> /etc/sysconfig/network-scripts/ifcfg-eth0

# Secure SSH
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

echo "
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys
AllowUsers root@50.191.168.56 serveradmin
" >> /etc/ssh/sshd_config

# Install Fail2Ban
systemctl enable fail2ban > /dev/null 2>&1
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
#sed -i 's/ignoreip = 127.0.0.1/8/ignoreip = 127.0.0.1/8 50.232.17.202 50.191.168.56/' /etc/fail2ban/jail.local

echo "
[sshd]
enabled  = true" >> /etc/fail2ban/jail.local

# Reboot for good measure
# echo " Oh Hi, I'm done but I'm going to reboot now"
# sleep 10
# shutdown -r now 'Bye Bye, See you soon!'