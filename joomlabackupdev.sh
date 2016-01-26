#!/bin/sh
#
# Backup script
# Written by Tom Reeb, Coriell Institute for Medical Research

# Set Variables

# Format: MONTH-DAY-YEAR (04-02-1987)
DATE=$(date +%m-%d-%Y)

#DocumentRoot for Joomla site
JOOMLA="/var/www/html/"

# MySQL backup file
MYSQLTARGET="/tmp/backup/backup-mysql-$DATE.sql"

# Target file
TARTARGET="/tmp/backup/backup-$DATE.tar.gz"

# MySQL dump
# you cannot have a space between the option and the password. If you omit the password value
# following the --password or -p option on the command line, you are prompted for one.
mysqldump -u wwwuser -pP^g4c0_r! coriell > $MYSQLTARGET

# Create Archive
tar -czvf $TARTARGET $MYSQLTARGET $JOOMLA

# Cleanup
# Find looks for files (-type f), this to exclude directories, that are older then 7 days (-mtime +7). 
# All it finds are passed to the rm command via xargs

find /tmp/backup -type f -mtime +7 | xargs rm





