#!/bin/bash

# check if script is executed as sudo
if [ "$EUID" -ne 0 ]
  then echo -e "\033[0;31mPlease run as root\033[0m"
  exit 1
fi

# Define Tomcat's variables
APACHE_HOME=/opt/tomcat
APACHE_BIN=$APACHE_HOME/bin
APACHE_WEBAPPS=$APACHE_HOME/webapps
APACHE_WEBAPPS_BACKUPS=$APACHE_HOME/webapps_backups

# Define product's variables
PRODUCT_SNAPSHOT_PATH=$1
PRODUCT_SNAPSHOT_NAME=$2

# Check if .war file exists
file=$PRODUCT_SNAPSHOT_PATH

if [ ! -f "$file" ]
then
  echo -e "\n\033[0;31mFile: ${file} does not exist; exiting\033[0m\n"
  exit 1
fi

# Remove the previous root deployment
# but back it up first
# cd $APACHE_WEBAPPS
# OLD_DEPLOYMENT=$(find . -name 'current*' | grep ".association" | sed 's/.\///')
# BACKUP_NAME=$(echo "$OLD_DEPLOYMENT" | sed 's/current-//' | sed 's/.association//')
# BACKUP_ARTIFACT_NAME="$BACKUP_NAME.war"
# sudo mv $APACHE_WEBAPPS/ROOT.war $APACHE_WEBAPPS_BACKUPS/$BACKUP_ARTIFACT_NAME

# Shutdown Tomcat
echo -e '\n\033[0;34mShutting down Tomcat\033[0m\n';
sh $APACHE_BIN/shutdown.sh

sleep 3

cd $APACHE_WEBAPPS
# PRODUCT_SNAPSHOT_NAME_RAW=$(echo "$PRODUCT_SNAPSHOT_NAME" | sed 's/.war//')
# touch "$PRODUCT_SNAPSHOT_NAME_RAW.association"
mv $PRODUCT_SNAPSHOT_PATH ROOT.war
chown tomcat:tomcat ROOT.war

# Start up Tomcat
echo -e '\n\033[0;34mStarting Tomcat\033[0m\n';
sh $APACHE_BIN/startup.sh

sleep 6

url=127.0.0.1
port=8080
status=$(wget --server-response --spider --quiet "${url}:${port}" 2>&1 | awk 'NR==1{print $2}')

if [ "$status" = "200" ]
then
  echo -e '\n\033[0;32mDeployment succeeded\033[0m\n';
else
  echo -e '\n\033[0;31mDeployment failed\033[0m'
  echo -e "\033[0;31mServer http error code: ${status}\033[0m\n"
  echo -e '\033[0;31mCheck log files under: /opt/tomcat/logs\033[0m\n'
  # rm $APACHE_WEBAPPS/ROOT.war 2> /dev/null
  # mv $APACHE_WEBAPPS_BACKUPS/$BACKUP_ARTIFACT_NAME $APACHE_WEBAPPS/ROOT.war 2> /dev/null
  exit 1
fi
