#!/bin/sh
#
# Rsync cron job for directory backup via nfs
# By: Tom Reeb

# Declaring some variables
DATE=$(date +%m-%d-%Y)
sourcedir=/nfs/backup/
destdir=/nfs/NV/
nfsserver=10.0.1.7
nfsexport=/c/home/tom
sudouser=nvbackup
logfile=/var/log/sharebackup-$DATE
smtp=10.0.1.25
mailfrom=admin@reeb.me
mailto=tom@reeb.me

# Let's make sure the destination is mounted
if [ $(mount | grep -c $destdir) != "1" ]; then
	mount -t nfs -o rw $nfsserver:$nfsexport $destdir
fi

# Ok now let's do the rsync thing
# If, for some reason, the backup share still does not mount, we don't want to run the command. So we're going to check again.
# I'm sure there's a better way to do this...
if [ $(mount | grep -c $destdir) != "1" ]; then
	sudo -u $sudouser rsync -rltzuvHKS $sourcedir $destdir > $logfile
else
	echo "ERROR: $destdir is not mounted. Backup did not run." > $logfile
fi

# E-mail results
mail -S smtp=$smtp -S from=$mailfrom -s "Share Backup - $DATE" $mailto < $logfile

# While we're at it, we should clean up the logs (We'll keep a weeks worth of logs)
find /var/log/sharebackup-* -type f -mtime +7 | xargs rm