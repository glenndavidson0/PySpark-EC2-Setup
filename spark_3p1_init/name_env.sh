#!/bin/sh
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca

# Read if the node is to be a Master or Worker Node from user
# Also accept the Master URL from the user at this time spark://<local-domain-name>:7077"

echo "IF WORKER NODE, PAUSE AT THIS STEP UNTIL MASTER SETUP IS COMPLETE"
echo "enter a node name to set env variable SPARK_NAME"
read spk_name
export SPARK_NAME=$spk_name
echo "enter the VPC master url (spark://<local-domain-name>:7077"
read master_name
export MASTER_URL=$master_name