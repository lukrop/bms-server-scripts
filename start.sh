#!/bin/sh
# Run Falcon BMS 4.33 U5 with wine.
# See README.md for usage information.  
# Author(s): Lukas Kropatschek <lukas@kropatschek.net>
# License: See LICENSE

BMS_LOGFILE=${BMS_LOGFILE:-"logs/bms.log"}
BMS_THEATER=${BMS_THEATER:-"Korea KTO"}
BMS_ARGS=${BMS_ARGS:-'-window'}
START_IVC=${START_IVC:-1}
PROMETHEUS_METRICS=${PROMETHEUS_METRICS:-0}
PROMETHEUS_FILE=${PROMETHEUS_FILE:-"/var/lib/prometheus/node-exporter/bms-fps.prom"}

BASEDIR="$PWD"
WINE_VERS="4.3-nodraw"
WINE_DIR="$PWD/wine/$WINE_VERS"
WINE="$WINE_DIR/bin/wine"
WINE64="$WINE_DIR/bin/wine64"
WINECONSOLE="$WINE_DIR/bin/wineconsole"

export WINEARCH="win64"
export WINEPREFIX="$PWD/wineprefix/bms"
export WINESERVER="$WINE_DIR/bin/wineserver"
export WINEDLLPATH="$WINE_DIR/lib/wine:$WINE_DIR/lib64/wine"

export PATH="$WINE_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$WINE_DIR/lib:$WINE_DIR/lib64:$LD_LIBRARY_PATH"

export WINEDEBUG="+timestamp,fixme-all,fps"
export LP_PERF=no_blend,no_depth,no_alphatest,no_mipmap,no_linear,no_mip_linear
#export LP_NUM_THREADS=4

BMS_PATH='C:\Falcon BMS 4.33 U1'
BMS_FPS="$BASEDIR/prometheus/bms-fps.sh"

# set theater
sed -ibak -e "s/\"curTheater\"=\".*\"$/\"curTheater\"=\"$BMS_THEATER\"/" $WINEPREFIX/system.reg

# start prometheus metrics export
if [ "$PROMETHEUS_METRICS" -eq 1 ]; then
	echo "Exposing metrics with prometheus."
	(
	sleep 5
	while /usr/bin/pgrep "Falcon BMS.exe" > /dev/null; do
		$BMS_FPS | sponge $PROMETHEUS_FILE
		sleep 5;
	done
	$BMS_FPS stop | sponge $PROMETHEUS_FILE
	) &
fi

if [ "$START_IVC" -eq 1 ]; then
	# launch IVC
	( $WINECONSOLE "$BMS_PATH\\Bin\\x86\\IVC\\IVC Server.exe" ) &
fi

# launch BMS
$WINE64 "$BMS_PATH\Bin\x64\Falcon BMS.exe" "$BMS_ARGS" 2>&1 | tee $BMS_LOGFILE
