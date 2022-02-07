#!/bin/sh
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca

# 1 - before running, an access .pem public/private token was created
# 2 - chmod 400 my-key-pair.pem was run on the key pair file - pre-requisitie to connection
# 3 - find the vm user name (ubuntu default) and public dns name after launching
# 4 - run this script passing in the DNS, uses default ubuntu user name and .pem in this directory
# 3 - runs the following command:
# ssh -i /path/my-key-pair.pem my-instance-user-name@my-instance-public-dns-name

if [ "$1" = "-h" ]
    then
        echo
	    echo Connects to a specified EC2 instance located at DNS
        echo input the instance public DNS to connect to as the first and only argument \$1
        echo default username \'ubuntu\' is used
        echo authorization used is \'gdavidson.pem\'
        echo
    else
        PATH2PEM='gdavidson.pem'
        INSTANCE_DNS=$1
        UNAME='ubuntu'
        UNAME_AT_DNS=$UNAME'@'$INSTANCE_DNS
        echo $UNAME_AT_DNS
        ssh -i $PATH2PEM $UNAME_AT_DNS
fi