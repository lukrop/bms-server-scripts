#!/bin/sh
# Retrieve BMS FPS metrics from logfile
# See README.md for usage information.  
# Author(s): Lukas Kropatschek <lukas@kropatschek.net>
# License: See LICENSE

BMS_LOGFILE=${BMS_LOGFILE:-"../logs/bms.log"}

echo "# HELP bms_fps Falcon BMS FPS running with wine"
echo "# TYPE bms_fps gauge"

if [ "$1" = "stop" ]
then 
	echo "# BMS is not running"
	echo "# bms_fps 0"
else 
	FPS=`cat $BMS_LOGFILE | sort -r | grep -m1 "trace:fps" | \
	       	grep -o '[0-9]*\.[0-9].fps' | cut -d'.' -f1`
	echo bms_fps $FPS
fi

