#!/bin/sh
#
# VPS Setup script
#

echo "Hello Tom! I am a script that you wrote to configure a new VPS!"
echo "First I am going to ask you a couple of questions"
#read -p "Enter the IP Address of the VPS: " -r vpsip
read -p "Enter the Hostname of the VPS: " -r vpshostname

#ssh root@$vpsip

# Add server admin user
useradd serveradmin
passwd serveradmin

mkdir /home/serveradmin/.ssh/

echo "serveradmin ALL=(ALL) ALL" >> /etc/sudoers
#exit
#read -p "Where is your local ssh public key located? [ex. /home/test/id_rsa.pub] " -r keyLoc 
#scp /Users/tom/.ssh/id_rsa.pub root@$vpsip:/home/serveradmin/.ssh/authorized_keys
chown -R serveradmin:serveradmin /home/serveradmin/
chmod 700 /home/serveradmin/.ssh/
chmod 600 /home/serveradmin/.ssh/authorized_keys
echo "Key authentication setup is complete."

#ssh root@$vpsip

# Install EPEL Repo
if grep -q -i "release 6" /etc/redhat-release
then
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -UvH http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
fi

if grep -q -i "release 7" /etc/redhat-release
then
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
	rpm -iv http://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm
fi

# Update System
yum -y update

# Install necessary packages
yum -y install python-pip htop tmux nano
pip install speedtest-cli

# Firewall
#EL6
if grep -q -i "release 6" /etc/redhat-release
then
chkconfig iptables on
service iptables start
fi
#EL7
if grep -q -i "release 7" /etc/redhat-release
then
systemctl enable firewalld.service
systemctl start firewalld.service
fi

# Sample Firewalld Commands
# firewall-cmd --list-services
# firewall-cmd --add-service openvpn
# firewall-cmd --permanent --add-service openvpn
# firewall-cmd --permanent --add-masquerade
# firewall-cmd --zone=public --add-port=8082/tcp --permanent
# firewall-cmd --zone=public --remove-port=8081/tcp --permanent
# firewall-cmd --add-masquerade
# firewall-cmd --query-masquerade

# Allow from specific IP
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="168.235.155.36" port port=8084 protocol="tcp" accept'
# Check Firewall config
# cat /etc/firewalld/zones/public.xml

# mount -t davfs https://cloud.reeb.me/remote.php/webdav/ /mnt/

#cp /usr/share/system-config-firewall/fw_n* ~
#yum -y remove system-config-firewall
#mv fw_n* /usr/share/system-config-firewall/
# Can now use system-config-firewall-tui to configure firewall after reboot

# Set Hostname
hostname $vpshostname
sed -i '/HOSTNAME/d' /etc/sysconfig/network
echo "HOSTNAME=cac-prod03.reeb.me" >> /etc/sysconfig/network

# CentOS 7
# hostnamectl set-hostname $vpshostname

# DNS Settings
#echo "
#nameserver 8.8.8.8
#nameserver 8.8.4.4
#search reeb.me
#" > /etc/resolv.conf

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
yum -y install Fail2Ban
systemctl enable fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

#Echo this line after [sshd]
echo "enabled = true" >> /etc/fail2ban/jail.local

# Disable SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Reboot
shutdown -r now 
