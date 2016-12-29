#!/bin/sh
#
# Rsync cron job for directory backup to Amazon Cloud Drive
# By: Tom Reeb

# acd_cli help
# First time: acd_cli init
# Sync:				acd_cli sync
# Usage:			acd_cli usage
# Mount:			acd_cli mount /local/mount/point
# Unmount:		acd_cli umount /local/mount/point

DATE=$(date +%m-%d-%Y)
sourcedir=/data/media/
destdir=/acd/media
logfile=/var/log/backup-$DATE
smtp=10.0.1.25
mailfrom=admin@reeb.me
mailto=tom@reeb.me


if [[ $(systemctl is-active acd.service) != active ]];then
  systemctl start acd.service
fi

if [ $(mount | grep -c $destdir) != "1" ]; then
	rsync -rltzuvHKS $sourcedir $destdir > $logfile
else
	echo "ERROR: $destdir is not mounted. Backup did not run." > $logfile
fi

mail -S smtp=$smtp -S from=$mailfrom -s "Media Backup - $DATE" $mailto < $logfile

find /var/log/backup-* -type f -mtime +7 | xargs rm
