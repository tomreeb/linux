#!/bin/sh
#
# Kiosk Mode startup script

# Disable screen blanking after 10 minutes

xset dpms 0 0 0
xset -dpms
xset s noblank
xset s noexpose

sleep 5

# Launch Chromium browser in Kiosk mode
chromium-browser --kiosk --disable-overlay-scrollbar --incognito http://catalogdev.coriell.org/1/Dashboard
