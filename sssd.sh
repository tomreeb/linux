#!/bin/sh
#
# Join a linux machine to Active Directory

# Install necessary packages
yum -y install realmd samba samba-common oddjob oddjob-mkhomedir sssd ntpdate ntp

# Enable and start NTP
systemctl enable ntpd.service
ntpdate corielldc01.coriell.org
systemctl start ntpd.service

# Join to AD
realm join --user=bind@coriell.org coriell.org

# SSSD Configuration

sed -i 's/default_domain_suffix = domain/default_domain_suffix = coriell.org/' /etc/sssd/sssd.conf

sed -i 's/use_fully_qualified_names = true/use_fully_qualified_names = False/' /etc/sssd/sssd.conf

systemctl enable sssd
systemctl start sssd

# Allow only linuxadmin AD gorup to login
realm permit -g linuxadmin@coriell.org
# Give sudo access to linuxadmin AD group
echo "linuxadmin@coriell.org    ALL=(ALL)       ALL"