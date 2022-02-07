#!/bin/sh
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca
# run this script (source) in each terminal used to ssh into EC2 instances so that IP/DNS adressess
#                                           are readily available as environment variables in shell

# after renting EC2 instances for the cluster, update the following environment variables:
export MASTER_DNS=""
export MASTER_DNS_PRIVATE=""
export MASTER_URL="spark://"$MASTER_DNS_PRIVATE":7077"
export MASTER_CONSOLE_URL=$MASTER_DNS":8080"
export NAMENODE_CONSOLE_URL=$MASTER_DNS":50070"
export WORKER1_DNS=""
export WORKER2_DNS=""
export WORKER3_DNS=""
#export WORKER4_DNS=""
#...

# example public EC2 DNS:
#export WORKER1_DNS="ec2-35-182-99-97.ca-central-1.compute.amazonaws.com"