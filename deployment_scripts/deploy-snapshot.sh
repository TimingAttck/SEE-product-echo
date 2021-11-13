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


APACHE_HOME=/opt/tomcat
APACHE_BIN=$APACHE_HOME/bin
APACHE_WEBAPPS=$APACHE_HOME/webapps
CANDIDATES_FOLDER=/home/vagrant/candidates
CANDIDATES_BACKUP_FOLDER=/home/vagrant/candidates_backups

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

# Copy the last deployment for possible rollbacks
commit_hash=$(sudo cat $CANDIDATES_FOLDER/ROOT.association)
sudo cp $CANDIDATES_FOLDER/ROOT.war $CANDIDATES_BACKUP_FOLDER/"$commit_hash".war

# Change the name of the current candidate to ROOT
mv $PRODUCT_SNAPSHOT_PATH $CANDIDATES_FOLDER/ROOT.war
commit_hash=${PRODUCT_SNAPSHOT_NAME%.*}
sudo echo "$commit_hash" > $CANDIDATES_FOLDER/ROOT.association

# Undeploy the last candidate (if any)
echo "Undeploy last candidate (if any)"
curl "http://admin:admin@127.0.0.1:8080/manager/text/undeploy?path=/"

# Remove cached files of the last deployment
cd $APACHE_HOME/work/Catalina/localhost/ROOT && rm -R *

# Freshly deploy the new candidate
echo "Deploy the new candidate"
DEPLOYMENT_OUTPUT=$(curl --upload-file $CANDIDATES_FOLDER/ROOT.war "http://admin:admin@127.0.0.1:8080/manager/text/deploy?path=")

if [ "$DEPLOYMENT_OUTPUT" != "OK - Deployed application at context path [/]" ]
then
  echo -e "\n\033[0;31mDeployment failed; Response did not match expected; expected response: 'OK - Deployed application at context path [/]'; actual response: '$DEPLOYMENT_OUTPUT'\033[0m\n"
  exit 1
fi