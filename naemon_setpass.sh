#!/bin/sh
# This script sets a users password in Naemon (nagios)
# Access the Web Console by http://nagios.coriell.org/naemon

echo -n "Enter the username: "

read username

htpasswd /etc/naemon/htpasswd $username

echo "Password for" $username "set!"