#!/bin/sh
#
# Add User Script (to make things easier)
#
# By: Tom Reeb - 3/10/16
#

#Check if run as root
if [ "$(whoami)" != "root" ] ; then
	echo "This script must be run as root"
	exit 1
fi

echo "********************************"
echo "**   User Account Creation    **"
echo "********************************"
echo ""

read -p "Enter the username for the account: " -r username

# Create user account and its directories
useradd -G admin -s /bin/bash $username
mkdir /home/$username
chown -R $username:$username /home/$username
chmod 770 /home/$username

echo "We need to set up pubkey authentication "
read -p "Paste the public key here: " -r pubkey
echo $pubkey
mkdir /home/$username/.ssh
touch /home/$username/.ssh/authorized_keys
echo $pubkey >> /home/$username/.ssh/authorized_keys
chown -R $username:$username /home/$username/
chmod 700 /home/$username/.ssh/
chmod 600 /home/$username/.ssh/authorized_keys
echo "Key authentication setup is complete."

echo "Account for $username has been created!"