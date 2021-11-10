#!/bin/bash


############################################
#                                          #
#           Simple Smoke testing           #
#         of a snapshot deployment         #
#                                          #
############################################

# CLI Arguments
ip_addr=$1
web_url=$2

# Ping the server to check if it is up and running
ping -c 2 $ip_addr
if [ $? -eq 1 ] 
then 
    echo "Server not reachable"
    exit 1
fi

# Check if the Web server responds with the correct http status code
# if the deployment failed tomcat will not respond with a 200 http status code
status=$(wget --server-response --spider --quiet "$web_url" 2>&1 | awk 'NR==1{print $2}')

if [ "$status" -eq "200" ]
then 
    echo "Deployment succeeded"
else 
    echo "Deployment failed; HTTP error code $status"
fi