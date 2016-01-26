#!/bin/sh
# Rise Vision install script
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y chromium-browser ttf-mscorefonts-installer htop unclutter

# Autostart
sudo mkdir ~/.config/autostart
sudo cp ./chrome-*******-Default.desktop ~/.config/autostart/*.*

# disable screen timeout

echo "
#!/bin/sh
xset s off
xset s noblank
xset -dpms
" > ~/disable_screen_timeout.sh

chmod +x ~/disable_screen_timeout.sh

sudo touch /usr/share/applications/disable_screen_timeout.desktop

sudo echo "
[Desktop Entry]
Name=Disable Screen Timeout
Exec=/home/pi/disable_screen_timeout.sh
Type=Application
Terminal=false
" > /usr/share/applications/disable_screen_timeout.desktop

sudo chmod +x /usr/share/applications/disable_screen_timeout.desktop

sudo cp /usr/share/applications/disable_screen_timeout.desktop ~/.config/autostart



