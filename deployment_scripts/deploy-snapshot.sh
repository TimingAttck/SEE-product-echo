#!/bin/bash


############################################
#                                          #
#         Deployment of a snapshot         #
#            to a Tomcat server            #
#                                          #
############################################


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


#
# the tomcat server sometimes just randomly fails to correctly restart
# and the worst thing is that it fails SILENTLY
# thus re-try the deployment at max 5 times when the server did not respond
# with the correct 200 http status code
#
status=""
trials=0
deploy() {

  # Shutdown Tomcat
  echo -e '\n\033[0;34mShutting down Tomcat\033[0m\n';
  sudo sh $APACHE_BIN/shutdown.sh

  sleep 6

  # Tomcat is such a bad application server, that its threads just sometimes get stuck 
  # and prevent starting a new instance, therefore kill them all
  pids=$(ps -awwef | grep tomcat | awk '{ print$2 }')
  if ! [ -z "$pid" ]
  then
    echo "$pids" | while read -r pid ; do
      sudo kill -15 $pid
    done
  fi


  # Copy the last deployment for possible rollbacks
  cd $APACHE_WEBAPPS_BACKUPS
  sudo cp $APACHE_WEBAPPS/ROOT.war ROOT.war
  commit_hash=$(sudo cat $APACHE_WEBAPPS/ROOT.association)
  sudo mv ROOT.war "$commit_hash".war


  # Remove previous snapshot .war files
  cd $APACHE_WEBAPPS
  sudo rm -R ROOT
  sudo rm ROOT.war


  # Copy the snapshot into the webapps folder
  sudo cp $PRODUCT_SNAPSHOT_PATH ROOT.war
  sudo chown tomcat:tomcat ROOT.war


  # Save the association file, needed for rollbacks
  commit_hash=${PRODUCT_SNAPSHOT_NAME%.*}
  sudo echo "$commit_hash" > ROOT.association


  # Start up Tomcat
  echo -e '\n\033[0;34mStarting Tomcat\033[0m\n';
  sudo sh $APACHE_BIN/startup.sh

  sleep 6

  # Send a request to the server and check its status code
  url=127.0.0.1
  port=8080
  status=$(wget --server-response --spider --quiet "${url}:${port}" 2>&1 | awk 'NR==1{print $2}')

  # Check the status code
  if [ "$status" = "200" ]
  then
    return 0
  else
    let "trials=trials+1"
  fi

  # Check if we have re-tried the deployment 5 times
  if [ "$trials" = "5" ]
  then
    return 1
  else
    # Recurisve call
    deploy
  fi

}

# Do the deployment
deploy

# Check the result of the deployment
if [ "$?" = "0" ]
then
  echo -e '\n\033[0;32mDeployment succeeded\033[0m\n';
else
  echo -e '\n\033[0;31mDeployment failed\033[0m'
  if ! [[ "$status" =~ ^[0-9]+$ ]]
  then
    echo -e "\033[0;31mServer is unreachable\033[0m\n"
  else
    echo -e "\033[0;31mServer http error code: ${status}\033[0m\n"
  fi
  echo -e '\033[0;31mCheck log files under: /opt/tomcat/logs\033[0m\n'
  exit 1
fi