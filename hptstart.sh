#!/bin/sh
#
# hptstart.sh
#
# Copy dat files
cp /mnt/z2array/scripts/hpt/*.dat /etc/

# Generate config file
echo "rr272x_1x" >> /etc/hptcfg

# Start server
hptsvr

# hptstop.sh
#
# Backup config files
#
#cp -rf /etc/hpt* /mnt/z2array/scripts/hpt/