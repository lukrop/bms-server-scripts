#!/bin/sh
# Bootstrap system for Falcon BMS 4.33
# See README.md for usage information.  
# Author(s): Lukas Kropatschek <lukas@kropatschek.net>
# License: See LICENSE

BMS_USER=${BMS_USER:-"bms"}
MANAGE_PACKAGES=${MANAGE_PACKAGES:-1}
VNC_SERVER_ARGS=${VNC_SERVER_ARGS:-"-localhost yes"}

echo "This script will bootstrap your system to be able to run"
echo "Falcon BMS 4.33 U5 via wine. Please read the README.md first."
read -p "Do you want to continue? (y/N) " CONTINUE

if [ "$CONTINUE" != "y" ]; then exit 0; fi

if [ "$MANAGE_PACKAGES" -eq "1" ]; then
	echo "Installing required software."
	dpkg --add-architecture i386
	apt-get -t stretch-backports -y --no-install-recommends install \
		xorg jwm wine wine32 wine64 winbind imagemagick aria2 \
		tigervnc-standalone-server tigervnc-common unzip
fi
echo "Adding user $BMS_USER to audio and video group"
usermod -a -G audio,video $BMS_USER

echo "Create a dummy sound device."
modprobe snd-dummy
if ! grep -q snd.dummy /etc/modules; then
	echo "Adding snd-dummy to /etc/modules"
	echo "snd-dummy" >> /etc/modules
fi

su $BMS_USER -c "cd ~ && vncserver $VNC_SERVER_ARGS"

echo "Bootstrapping complete. Conitnue with install.sh"
