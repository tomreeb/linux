#!/bin/sh

clear
echo "######################################################"
echo "######  Welcome to sBorg transmission installer ######"
echo "######################################################"
echo "";
echo "Enter the version of centos you are using (5 or 6 only), followed by [ENTER]:"
read centos_version
echo "";
echo "Enter the username for your transmission WebUI, followed by [ENTER]:"
read tr_username
echo "Enter the password for your transmission WebUI, followed by [ENTER]:"
read tr_password

if [ "$centos_version" == "6" ]; then
	wget http://sborg.us/sh/transmission/geekery-el6.repo
	mv geekery-el6.repo /etc/yum.repos.d/geekery-el6.repo
else
	wget http://sborg.us/sh/transmission/geekery-el5.repo
	mv geekery-el5.repo /etc/yum.repos.d/geekery-el5.repo
fi

echo "######  Installing Transmission ######"
yum --enablerepo=geekery transmission-daemon -y

echo "######  Adding firewall exception ######"
echo "-A INPUT -p tcp -m tcp --dport 9091 -j ACCEPT" > /etc/sysconfig/iptables
/etc/init.d/iptables restart

echo "######  Loading Transmission ######"
transmission-daemon -a 127.0.0.1,*.*.*.* -t -u "$tr_username" -v "$tr_password"

echo "######  Transmission Installed. Transmission running at: ######"
echo ""
echo "http://$HOSTNAME:9091/"
echo ""
echo "After server restart, run this command to restart transmission"
echo ""
echo "transmission-daemon"
echo ""

