#!/bin/bash
# Install Falcon BMS 4.33 U5
# See README.md for usage information.  
# Author(s): Lukas Kropatschek <lukas@kropatschek.net>
# License: See LICENSE

DOWNLOAD_BMS=${DOWNLOAD_BMS:-1}
DOWNLOAD_WINE=${DOWNLOAD_WINE:-1}
INSTALL_FALCON_4=${INSTALL_FALCON_4:-1}
INSTALL_BMS=${INSTALL_BMS:-1}
TWEAK_CONFIG=${TWEAK_CONFIG:-1}
RESIZE_TEXTURES=${RESIZE_TEXTURES:-1}
SEED_TIME=${SEED_TIME:-15}

WINE_VERS="4.3-nodraw"

BASEDIR="$PWD"
WINE_DIR="$PWD/wine/$WINE_VERS"
WINE="$WINE_DIR/bin/wine"
WINE64="$WINE_DIR/bin/wine64"

export WINEARCH="win64"
export WINEPREFIX="$PWD/wineprefix/bms"
export WINESERVER="$WINE_DIR/bin/wineserver"
export WINEDLLPATH="$WINE_DIR/lib/wine:$WINE_DIR/lib64/wine"
export WINEDEBUG="fixme-all"

export PATH="$WINE_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$WINE_DIR/lib:$WINE_DIR/lib64:$LD_LIBRARY_PATH"

echo "This script will install Falcon BMS 4.33 U5 with wine"
echo "Please see the README.md for more details."
read -p "Do you want to continue? (y/N) " CONTINUE

if [ "$CONTINUE" != "y" ]; then exit 0; fi

BMS_PATH=`winepath 'C:\Falcon BMS 4.33 U1'`
BMS_CONFIG="$BMS_PATH/User/Config/Falcon BMS.cfg"

# Download and extract patched version of wine
if [ "$DOWNLOAD_WINE" -eq "1" ]; then
	cd $BASEDIR/wine
	aria2c "https://github.com/lukrop/wine/releases/download/wine-$WINE_VERS\
/wine-$WINE_VERS.tar.bz2"
	tar xvjf wine-$WINE_VERS.tar.bz2
fi

# Use SteamCmd to install Falcon 4.0
if [ "$INSTALL_FALCON_4" -eq "1" ]; then
	STEAM_PATH=`winepath 'C:\steamcmd'`
	mkdir -p $STEAM_PATH
	cd $STEAM_PATH
	aria2c "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
	unzip steamcmd.zip
	echo "Please provide your Steam credentials. Password will not be echoed."
	read -p "Username: " STEAM_USER
	echo -n "Password: "
	read -s STEAM_PASSWORD
	$WINE steamcmd +login $STEAM_USER $STEAM_PASSWORD +app_update 429530 \
			validate +quit
	# Sadly it doesnt't work adding the registry entries via the .vdf script
	#$WINE $STEAM_PATH/bin/steamservice /installscript \
	#      "$STEAM_PATH/steamapps/common/Falcon 4.0/InstallScript_F4_CombinedOS.vdf" 429530
	# So we are using a registry file
	$WINE regedit $BASEDIR/falcon4.reg
fi

# Download Falcon BMS install files
if [ "$DOWNLOAD_BMS" -eq "1" ]; then
	cp $BASEDIR/torrent/Falcon_BMS_4.33_U*.torrent $BASEDIR/sources/
	cd $BASEDIR/sources
	aria2c --seed-time=$SEED_TIME $BASEDIR/sources/Falcon_BMS_4.33_U*.torrent
	rm $BASEDIR/sources/Falcon_BMS_4.33_U*.torrent
fi
# Install Falcon BMS using wine
if [ "$INSTALL_BMS" -eq "1" ]; then
	cd $BASEDIR/sources
	unzip Falcon_BMS_4.33_U1_Setup.zip
	ln -s $BASEDIR/sources/Falcon\ BMS\ 4.33\ U1\ Setup/ `winepath c:\\`
	$WINE 'C:\Falcon BMS 4.33 U1 Setup\Setup.exe'
	$WINE Falcon_BMS_4.33_U2_Incremental.exe
	$WINE Falcon_BMS_4.33_U3_Incremental.exe
	$WINE Falcon_BMS_4.33_U4_Incremental.exe
	$WINE Falcon_BMS_4.33_U5_Incremental.exe
fi

# Tweak the Falcon BMS configuration for best performance
if [ "$TWEAK_CONFIG" -eq "1" ]; then
	cp "$BMS_CONFIG" "$BMS_CONFIG.bak"
	sed -i -e 's/DefaultFOV .*/DefaultFOV 20/' "$BMS_CONFIG"
	sed -i -e 's/PlayIntroMovie .*/PlayIntroMovie 0/' "$BMS_CONFIG"
	sed -i -e 's/HiResTextures .*/HiResTextures 0/' "$BMS_CONFIG"
	sed -i -e 's/ReducePSFires .*/ReducePSFires 1/' "$BMS_CONFIG"
	sed -i -e 's/EnvironmentalMapping .*/EnvironmentalMapping 0/' "$BMS_CONFIG"
	sed -i -e 's/PixelLighting .*/PixelLighting 0/' "$BMS_CONFIG"
	sed -i -e 's/VertexLighting .*/VertexLighting 1/' "$BMS_CONFIG"
	sed -i -e 's/HdrLighting .*/HdrLighting 0/' "$BMS_CONFIG"
	sed -i -e 's/HdrLightingStar .*/HdrLightingStar 0/' "$BMS_CONFIG"
	sed -i -e 's/UseHeatHazeShader .*/UseHeatHazeShader 0/' "$BMS_CONFIG"
	sed -i -e 's/UseMotionBlurShader .*/UseMotionBlurShader 0/' "$BMS_CONFIG"
	sed -i -e 's/ShowFarRain .*/ShowFarRain 0/' "$BMS_CONFIG"
	sed -i -e 's/ShowRainDrops .*/ShowRainDrops 0/' "$BMS_CONFIG"
	sed -i -e 's/ShowRainRings .*/ShowRainRings 0/' "$BMS_CONFIG"
	sed -i -e 's/ShadowMapping .*/ShadowMapping 0/' "$BMS_CONFIG"
	sed -i -e 's/CockpitShadows .*/CockpitShadows 0/' "$BMS_CONFIG"
	sed -i -e 's/FocusShadows .*/FocusShadows 0/' "$BMS_CONFIG"
	sed -i -e 's/ShadowsOnSmoke .*/ShadowMapping 0/' "$BMS_CONFIG"
	sed -i -e 's/WaterNormalMapping .*/WaterNormalMapping 0/' "$BMS_CONFIG"
	sed -i -e 's/WaterEnvironmentMapping .*/WaterEnvironmentMapping 0/' "$BMS_CONFIG"
	sed -i -e 's/EnvMapRenderClouds .*/EnvMapRenderClouds 0/' "$BMS_CONFIG"
	sed -i -e 's/EnvMapRenderFocusObject .*/EnvMapRenderFocusObject 0/' "$BMS_CONFIG"
	sed -i -e 's/TripleBuffering .*/TripleBuffering 0/' "$BMS_CONFIG"
	sed -i -e 's/MaximumFOV .*/MaximumFOV 20/' "$BMS_CONFIG"
	sed -i -e 's/TripleBuffering .*/TripleBuffering 0/' "$BMS_CONFIG"
	sed -i -e 's/UseTerrainNightLightsTextureFilter .*/UseTerrainNightLightsTextureFilter 0/' "$BMS_CONFIG"
	sed -i -e 's/EnableExclusiveMouseCapture .*/EnableExclusiveMouseCapture 0/' "$BMS_CONFIG"
	sed -i -e 's/ExportRTTTextures .*/ExportRTTTextures 0/' "$BMS_CONFIG"
	sed -i -e 's/DoubleRTTResolution .*/DoubleRTTResolution 0/' "$BMS_CONFIG"

	# Make sure the server flight doesn't get bumped back into 2D
	sed -i -e 's/PlayerBumpTime = .*/PlayerBumpTime = 43200/' "$BMS_PATH/Data/Campaign/Save/atc.ini"
	sed -i -e 's/PlayerBumpTime = .*/PlayerBumpTime = 43200/' "$BMS_PATH/Data/Add-On Korea Strong DPRK/Campaign/atc.ini"
fi

if [ "$RESIZE_TEXTURES" -eq "1" ]; then
	cd $BASEDIR
	DATADIR="$BMS_PATH/Data/Terrdata" ./resize_textures.sh
fi
