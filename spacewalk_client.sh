#!/bin/sh
#
echo"
####################################################
###  SPACEWALK CLIENT INSTALLATION/REGISTRATION  ###
####################################################
"
# Script must be run as root user
# If the client has already been registered, delete /etc/sysconfig/rhn/systemid

# add the spacewalk repo and use yum to install the client and deps
if grep -q -i "release 6" /etc/redhat-release
then
	rpm -Uvh http://yum.spacewalkproject.org/2.4-client/RHEL/6/x86_64/spacewalk-client-repo-2.4-3.el6.noarch.rpm
fi

# Version 7
if grep -q -i "release 7" /etc/redhat-release
then
	rpm -Uvh http://yum.spacewalkproject.org/2.4-client/RHEL/7/x86_64/spacewalk-client-repo-2.4-3.el7.noarch.rpm
fi

yum -y install perl-Nagios-Plugin rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin osad rhncfg rhncfg-actions rhncfg-client

# The next step runs the registration. 
# Make sure to change the activation key if necessary, but this is the default repository
# 

wget -P /usr/share/rhn http://spacewalk.coriell.org/pub/RHN-ORG-TRUSTED-SSL-CERT

rhnreg_ks --serverUrl=https://spacewalk.coriell.org/XMLRPC --activationkey=1-spacewalk
# rhnreg_ks --serverUrl=https://spacewalk.coriell.org/XMLRPC --activationkey=1-centos6
# rhnreg_ks --serverUrl=https://spacewalk.coriell.org/XMLRPC --activationkey=1-centos7

# To re-register a client (after a clone, etc) use this command:
# sudo rhnreg_ks --serverUrl=https://spacewalk.coriell.org/XMLRPC --activationkey=1-spacewalk --force

# Remove public repositories

yum clean all

mkdir /tmp/repobackup

mv /etc/yum.repos.d/*.repo /tmp/repobackup/

# Clean yum

yum clean all

# osad configuration
if grep -q -i "release 6" /etc/redhat-release
then
	chkconfig osad on
	service osad start
fi

if grep -q -i "release 7" /etc/redhat-release
then
	systemctl enable osad
	systemctl start osad
fi

# Configuration Management

rpm --import http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2014
rpm --import http://yum.spacewalkproject.org/RPM-GPG-KEY-spacewalk-2015

rhn_check

rhn-actions-control --enable-all
