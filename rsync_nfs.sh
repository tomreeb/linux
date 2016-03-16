#!/bin/sh
#
# Rsync cron job for directory backup via nfs
# By: Tom Reeb

# Declaring some variables
DATE=$(date +%m-%d-%Y)
sourcedir=/data/media/
destdir=/nfs/media/
nfsserver=10.0.1.8
nfsexport=/mnt/data/media
logfile=/var/log/backup-$DATE
smtp=10.0.1.25
mailfrom=admin@reeb.me
mailto=tom@reeb.me

# Let's make sure the destination is mounted
if [ $(mount | grep -c $destdir) != "1" ]; then
	mount -t nfs $nfsserver:$nfsexport $destdir
fi

# Ok now let's do the rsync thing
# If, for some reason, the backup share still does not mount, we don't want to run the command. So we're going to check again.
# I'm sure there's a better way to do this...
if [ $(mount | grep -c $destdir) != "1" ]; then
	rsync -avuhO $sourcedir $destdir > $logfile
else
	echo "ERROR: $destdir is not mounted. Backup did not run." > $logfile
fi

# E-mail results
mail -S smtp=$smtp -S from=$mailfrom -s "Media Backup - $DATE" $mailto < $logfile

# While we're at it, we should clean up the logs (We'll keep a weeks worth of logs)
find /var/log/backup-* -type f -mtime +7 | xargs rm