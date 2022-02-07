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
	    echo "Transfers a file to a running EC2 instance:"
        echo "Argument 1 = Source file + path (local machine)"
        echo "Argument 2 = Destination path on running instance (remote machine)"
        echo "Argument 3 = Instance DNS"
        echo
    else
        SOURCE_FILEPATH=$1
        PEM_FILEPATH='gdavidson.pem'
        INSTANCE_DNS=$3
        UNAME='ubuntu'
        UNAME_AT_DNS=$UNAME'@'$INSTANCE_DNS
        REMOTE_DESTINATION=$UNAME_AT_DNS':'$2
        echo
        echo "Destination:"
        echo $DESTINATION
        scp -i $PEM_FILEPATH $SOURCE_FILEPATH $REMOTE_DESTINATION 
fi