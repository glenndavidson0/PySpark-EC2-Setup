#!/bin/sh
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca

# The format of the command is:
# scp -i /path/my-key-pair.pem /path/my-file.txt ec2-user@my-instance-public-dns-name:path/

# example:
# scp -i gdavidson.pem setup.zip ubuntu@ec2-35-183-97-112.ca-central-1.compute.amazonaws.com:/home/ubuntu

if [ "$1" = "-h" ]
    then
        echo
	    echo "Downloads a file from an EC2 instance at a specified path:"
        echo "Argument 1 = Path + Source file name (remote filepath)"
        echo "Argument 2 = Destination path on local machine (local filepath)"
        echo "Argument 3 = Instance DNS"
        echo
    else
        SOURCE_FILEPATH=$1
        LOCAL_FILEPATH=$2
        PEM_FILEPATH='gdavidson.pem'
        INSTANCE_DNS=$3
        UNAME='ubuntu'
        UNAME_AT_DNS=$UNAME'@'$INSTANCE_DNS
        REMOTE_FILEPATH=$UNAME_AT_DNS':'$SOURCE_FILEPATH
        echo
        echo "Destination:"
        echo $LOCAL_FILEPATH
        scp -i $PEM_FILEPATH $REMOTE_FILEPATH $LOCAL_FILEPATH 
fi