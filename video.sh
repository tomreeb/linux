#!/bin/sh

# By: Tom Reeb, 4/7/16
#
# Usage: video.sh video.ext

if [ $# -ne 1 ]
then
    echo "Usage: $(basename $0) VIDEOFILE.ext"
    exit 1
fi

VIDEOFILE=$1

sudo killall chromium-browser
sudo chmod a+rw /dev/vchiq
omxplayer -p -o hdmi $VIDEOFILE --loop --no-osd &
