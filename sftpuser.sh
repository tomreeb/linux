#!/bin/sh
# This script is used to create an account for SFTP access on sftp01
# Please refer to the SFTP documentation on the IT Wiki for more information.

echo "********************************"
echo "** SFTP User Account Creation **"
echo "********************************"
echo ""

read -p "Enter the username for the sftp account: " -r username

# Create user account and its directories
useradd -s /bin/false -g sftp $username
mkdir /sftp_root/sftpusers/home/$username
chown -R $username:smb /sftp_root/sftpusers/home/$username
chmod 770 /sftp_root/sftpusers/home/$username

# Ask about authentication methods

read -p "Will $username authenticate with a Password? [default: No] " -r passAuth
		if [[ $passAuth =~ ^([yY][eE][sS]|[yY])$ ]]; then
    		passwd $username
    		echo "Password for $username has been set."
    	else
    		echo "Moving on without setting password."
		fi

read -p "Will $username authenticate with a key [default: Yes] " -r keyAuth
		if [[ -z "$keyAuth" || $keyAuth =~ ^([yY][eE][sS]|[yY])$ ]]; then
            read -p "Where is the key located? [ex. /home/test/id_rsa.pub] " -r keyLoc
            mkdir /home/$username/.ssh
            touch /home/$username/.ssh/authorized_keys
            cat $keyLoc >> /home/$username/.ssh/authorized_keys
            chown -R $username:sftp /home/$username/
            chmod 700 /home/$username/.ssh/
			chmod 600 /home/$username/.ssh/authorized_keys
			echo "Key authentication setup is complete."
		else
   			echo "Key authentication is preferred, you should think about adding a key later."
        fi

echo "SFTP account for $username has been created!"