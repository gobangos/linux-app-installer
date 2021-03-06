#!/bin/bash
##########################################################################
# This script configures aMule daemon to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.1
# Last modified date (dd/mm/yyyy): 15/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Variables
AMULE_DOWNLOAD_FOLDER="$homeDownloadFolder/aMule"
TEMP_FOLDER="$homeFolder/.Temporal"
AMULE_TEMP_FOLDER="$TEMP_FOLDER/aMule"
AMULE_ACCEPT_EXTERNAL_CONNECTIONS=1
AMULE_EXTERNAL_CONNECTION_PASSWORD="amule"
AMULE_EXTERNAL_CONNECTION_PORT="4712"
AMULE_ENABLE_WEB_SERVER=1
AMULE_WEB_SERVER_PASSWORD="amule"
AMULE_WEB_SERVER_PORT="4711"

# Pre-requisites
apt-get -y install gksu
# Create the necessary folders
mkdir -p $AMULE_DOWNLOAD_FOLDER $AMULE_TEMP_FOLDER $homeFolder/.aMule
chown -R $username:$username $AMULE_DOWNLOAD_FOLDER $TEMP_FOLDER $homeFolder/.aMule/

# Create backup of config files
sudo -u $username cp $scriptRootFolder/etc/amule.conf $homeFolder/.aMule/
sudo -u $username cp $homeFolder/.aMule/amule.conf $homeFolder/.aMule/amule.conf.backup
cp /etc/default/amule-daemon /etc/default/amule-daemon.backup

# Set variables in amule config file
sudo -u $username sed -i "s@^IncomingDir=.*@IncomingDir=$AMULE_DOWNLOAD_FOLDER@g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s@^TempDir=.*@TempDir=$AMULE_TEMP_FOLDER@g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^AcceptExternalConnections=.*/AcceptExternalConnections=$AMULE_ACCEPT_EXTERNAL_CONNECTIONS/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^ECPassword=.*/ECPassword=`echo -n $AMULE_EXTERNAL_CONNECTION_PASSWORD | md5sum | cut -d ' ' -f 1`/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^ECPort=.*/ECPort=$AMULE_EXTERNAL_CONNECTION_PORT/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^Enabled=.*/Enabled=$AMULE_ENABLE_WEB_SERVER/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^Password=.*/Password=`echo -n $AMULE_WEB_SERVER_PASSWORD | md5sum | cut -d ' ' -f 1`/g" $homeFolder/.aMule/amule.conf
sudo -u $username sed -i "s/^Port=.*/Port=$AMULE_WEB_SERVER_PORT/g" $homeFolder/.aMule/amule.conf

# Set username in amule-daemon's config file
sed -i "s/AMULED_USER=\"\"/AMULED_USER=\"$username\"/g" /etc/default/amule-daemon

# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"

# Create menu launcher for amule-daemon's web client.
echo "[Desktop Entry]
Name=aMule Web
Exec=xdg-open http://localhost:$AMULE_WEB_SERVER_PORT
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=aMule Web" > /usr/share/applications/amuled-web.desktop

# Create menu launcher to start amule-daemon.
echo "[Desktop Entry]
Name=aMule daemon start
Exec=gksudo /etc/init.d/amule-daemon start
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start aMule server" > /usr/share/applications/amuled-start.desktop

# Create menu launcher to stop amule-daemon.
echo "[Desktop Entry]
Name=aMule daemon stop
Exec=gksudo /etc/init.d/amule-daemon stop
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop aMule server" > /usr/share/applications/amuled-stop.desktop

# Start amule-daemon
service amule-daemon start

