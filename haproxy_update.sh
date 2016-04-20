#!/bin/bash
#
# HAProxy Upgrade Script!
#
# Written by Tom Reeb, January 13th 2015
# - Initial Commit
# Version 1.1 updated November 11th 2015
# - bugs
# Version 1.2 updated January 26th 2016
# - Added root user check
# - Added support for EL7 systems
# - Added support for versions greater than 1.5
# - Added support to pass version as command line argument i.e. "$ ./haproxy_update.sh 1.6.1"
#

# Check Root user
if [ `whoami` != 'root' ]; then
	echo "You must be root to upgrade HAProxy"
	exit 1
else
	echo "Welcome to the HAProxy upgrade script!"
fi

# Setting the version to upgrade to
haproxyver="$1"
if [[ -z "$1" ]]; then
read -p "What is the latest version of HAProxy? [e.g. 1.6.1]: " -r haproxyver
fi
echo "This will install HAProxy version $haproxyver"
read -p "Are you sure you want to continue? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo "Ok, bye!"
    exit 1
fi

# Download the File
if [[ "$haproxyver" == 1.5* ]]
then 
	wget -P /tmp/ http://www.haproxy.org/download/1.5/src/haproxy-$haproxyver.tar.gz
elif [[ "$haproxyver" == 1.6* ]]
then 
	wget -P /tmp/ http://www.haproxy.org/download/1.6/src/haproxy-$haproxyver.tar.gz
else 
	echo "I'm sorry, $haproxyver is not supported at this time."
	exit 1
fi

# Now back to the good part
# Stop Service
if grep -q -i "release 6" /etc/redhat-release
	then service haproxy stop
elif grep -q -i "release 7" /etc/redhat-release
	then systemctl stop haproxy.service
fi

tar zxpf /tmp/haproxy-$haproxyver.tar.gz -C /tmp/
cd /tmp/haproxy-$haproxyver
# Compile
make -j4 TARGET=linux26 USE_LINUX_TPROXY=1 USE_PCRE=1 USE_OPENSSL=1 ARCH=$(uname -m) PCRE_LIB=/usr/lib64 SSL_LIB=/usr/lib64
make install
cp -f /usr/local/sbin/haproxy* /usr/sbin/
# Clean up
rm -rf /tmp/haproxy*

# Start Service and ensure it is enabled to autostart
if grep -q -i "release 6" /etc/redhat-release
	then 
		chkconfig haproxy on
		service haproxy start
elif grep -q -i "release 7" /etc/redhat-release
	then 
		systemctl enable haproxy.service
		systemctl start haproxy.service
fi