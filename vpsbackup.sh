#!/bin/sh
#
# cac-prod01.reeb.me backup script
# Backing up data and configuration for tomreeb.com, OwnCloud, Postfix/Dovecot/Roundcube Mail setup,
# SSL Certificates, MariaDB Databases for OwnCloud and Roundcube

# Be sure to include the passwords while running script i.e. "$ ./script.sh ocdbpass rcdbpass 7zippass"

# Begin Script
# Set Variables

# Format: MONTH-DAY-YEAR (04-02-1987)
DATE=$(date +%m-%d-%Y)

# Passwords
OCDBPASS="$1"
RCDBPASS="$2"
7ZPASS="$3"

# HAProxy Config Location
HAPROXY="/etc/haproxy/"

# Nginx Config Location
NGINXCFG="/etc/nginx/"

# Postfix Config Location
POSTFIXCFG="/etc/postfix"

# Dovecot Config Location
DOVECOTCFG="/etc/dovecot"

# SSL Cert Location
SSLCFG="/etc/pki/tls/certs"

# Root locations for nginx sites
CLOUD="/usr/share/nginx/cloud"
WWW="/usr/share/nginx/v5"
RCUBE="/usr/share/nginx/roundcube"

# Create temp dir
WORKDIR="/tmp/backup-$DATE"
mkdir $WORKDIR

# MariaDB backup files
OCDB="$WORKDIR/backup-ownclouddb-$DATE.sql"
RCDB="$WORKDIR/backup-roundcubedb-$DATE.sql"

# Target file
ZIPTARGET="/tmp/backup/backup-$DATE.7z"

#########################################################################
# Create Archives
tar -cjf $WORKDIR/haproxy-$DATE.tar.bz2 -C $HAPROXY .
tar -cjf $WORKDIR/nginxcfg-$DATE.tar.bz2 -C $NGINXCFG .
tar -cjf $WORKDIR/postfixcfg-$DATE.tar.bz2 -C $POSTFIXCFG .
tar -cjf $WORKDIR/dovecotcfg-$DATE.tar.bz2 -C $DOVECOTCFG .
tar -cjf $WORKDIR/sslcfg-$DATE.tar.bz2 -C $SSLCFG .
tar -cjf $WORKDIR/cloud-$DATE.tar.bz2 -C $CLOUD .
tar -cjf $WORKDIR/www-$DATE.tar.bz2 -C $WWW .
tar -cjf $WORKDIR/roundcube-$DATE.tar.bz2 -C $RCUBE .

# Backup Databases 
mysqldump --add-drop-table -h localhost -u ocuser -p$OCDBPASS ownclouddb > $OCDB
mysqldump --add-drop-table -h localhost -u rcuser -p$RCDBPASS roundcube > $RCDB

# Create Archive
7za a -p$7ZPASS -r $ZIPTARGET $WORKDIR

# Copy backup file to Box.com
#rsync -P $ZIPTARGET.7z /box/vps_backup/

# Cleanup
# Delete temp dir
rm -rf $WORKDIR

# Find looks for files (-type f), this to exclude directories, that are older then 1 day (-mtime +1, -mmin +1440). 
# All it finds are passed to the rm command via xargs
find /tmp/backup -type f -mmin +1440 | xargs rm
#find /box/vps_backup -type f -mtime +4 | xargs rm

# End Script