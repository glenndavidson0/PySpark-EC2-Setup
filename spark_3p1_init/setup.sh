#!/bin/sh
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca
# Spark, Hadoop, Anaconda setup script for PySpark programming

# define the location of packages to download from internet
ANACONDA_DOWNLOAD_URL="https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh"
HADOOP_DOWNLOAD_URL="https://archive.apache.org/dist/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz"
SPARK_DOWNLOAD_URL="https://mirror.its.dal.ca/apache/spark/spark-3.1.2/spark-3.1.2-bin-hadoop2.7.tgz"
ANACONDA_SETUP="Anaconda3-5.3.1-Linux-x86_64.sh"
HADOOP_PKG="hadoop-2.7.2.tar.gz"
SPARK_PKG="spark-3.1.2-bin-hadoop2.7.tgz"

# cluster settings - instance and application specific
EXECUTOR_MEMORY="SPARK_EXECUTOR_MEMORY=12G"
DRIVER_MEMORY="spark.driver.memory 24g"
MAX_RESULT_SIZE="spark.driver.maxResultSize 2g"

# perform updates and install packages available through apt
sudo apt -y update
sudo apt -y upgrade
mkdir Utilities
mkdir Documents
sudo apt install openjdk-8-jre-headless -y
sudo apt install scala unzip make gcc -y

# add java to PATH and set JAVA_HOME in environment
sudo mv /etc/environment /etc/environment1.bak
sudo touch /etc/environment
sudo cp environment1 /etc/environment

# download Anaconda, Hadoop, Spark
curl -O $ANACONDA_DOWNLOAD_URL
wget $HADOOP_DOWNLOAD_URL
wget $SPARK_DOWNLOAD_URL

# auto install Anaconda, and add to bashrc 
bash $ANACONDA_SETUP -b -p $HOME/anaconda3
echo ". /home/ubuntu/anaconda3/etc/profile.d/conda.sh" >> ~/.bashrc
rm $ANACONDA_SETUP

# Install Hadoop at path /opt/hadoop
tar xvzf $HADOOP_PKG
rm $HADOOP_PKG
sudo mv hadoop-2.7.2 /opt/hadoop

# Set enviornment variables for Hadoop, and change hadoop configurations
# (core-site.xml,hdfs-site.xml,hosts) are part of server setup pkg
# (hosts file should contain the aliases for all nodes in the cluster before this stage)
echo "export HADOOP_HOME=/opt/hadoop" >> ~/.bashrc
echo "export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop" >> ~/.bashrc
source ~/.bashrc
cp ~/hdfs_config/core-site.xml $HADOOP_CONF_DIR
cp ~/hdfs_config/hdfs-site.xml $HADOOP_CONF_DIR
sudo cp ~/hdfs_config/hosts /etc/hosts

# install spark to /opt/spark
tar xvzf $SPARK_PKG
rm $SPARK_PKG
sudo mv spark-3.1.2-bin-hadoop2.7 /opt/spark/

# set SPARK_HOME environment variable, add /opt/spark/bin to PATH
sudo mv /etc/environment /etc/environment2.bak
sudo touch /etc/environment
sudo cp environment2 /etc/environment
source /etc/environment
source ~/.bashrc

# create conda python environment called 'spark', install packages:
#                              requests, pandas, spacy, textblob, 
#                         and install nlp data for textblob and spacy
conda activate base
conda create -n spark python=3.9 requests pandas spacy -y
conda activate spark
python -m spacy download en_core_web_sm
pip install textblob
python -m textblob.download_corpora

# add SPARK_HOME to PYTHONPATH, this is essential, allowing python to find the pyspark libraries
export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH

# create spark configuration
cd /opt/spark/conf
cp log4j.properties.template  log4j.properties
cp spark-defaults.conf.template spark-defaults.conf
cp spark-env.sh.template  spark-env.sh 

# Additions to spark-env.sh: 
echo "export HADOOP_HOME=/opt/hadoop" >> spark-env.sh
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$HADOOP_HOME/lib/native" >> spark-env.sh
echo "PYSPARK_PYTHON=/home/ubuntu/anaconda3/envs/spark/bin/python3" >> spark-env.sh

# allow the user to decide if the node is setup as a master or a worker
#                requires manual intervention by user (sets SPARK_NAME)
# also set the environment variable MASTER_DNS, which is the private DNS
#                   that worker nodes use to communicate with the master
source /home/ubuntu/name_env.sh

if [ "$SPARK_NAME" = "MASTER" ]
    then
        # add to spark env.sh
        echo $EXECUTOR_MEMORY >> spark-env.sh
        
        # Added settings to spark-defaults.conf
        echo "IS MASTER:"
        echo "spark.eventLog.enabled true" >> spark-defaults.conf
        echo "spark.eventLog.dir file:///tmp/spark-events" >> spark-defaults.conf
        echo "spark.history.fs.logDirectory file:///tmp/spark-events" >> spark-defaults.conf
        echo $DRIVER_MEMORY >> spark-defaults.conf
        echo $MAX_RESULT_SIZE >> spark-defaults.conf

        # Start history server daemon
        mkdir -p /tmp/spark-events
        bash /opt/spark/sbin/start-history-server.sh
        
        # start spark master node daemon
        bash /opt/spark/sbin/start-master.sh
        
        # add ssh private key for HDFS Master-Worker communication
        cat ~/keys/id_rsa.pub >> ~/.ssh/authorized_keys
        cp ~/keys/id_rsa ~/.ssh
        chmod 0600 ~/.ssh/authorized_keys
        rm -rf ~/keys

        # Hadoop configuration: namenode storage, set JAVA_HOME in hadoop-env.sh, HDFS slaves file
        mkdir -p /home/ubuntu/hadoop_store/hdfs/namenode
        cd ~/usrpylib
        python replace_first_occurance.py $HADOOP_CONF_DIR/hadoop-env.sh 'export JAVA_HOME=${JAVA_HOME}' 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"'
        cp ~/hdfs_config/slaves $HADOOP_HOME/etc/hadoop/slaves

        # format HDFS and launch namenode
        $HADOOP_HOME/bin/hdfs namenode -format cluster1
        $HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
    else
        echo "IS WORKER:"

        # launch spark worker daemon
        bash /opt/spark/sbin/start-worker.sh $MASTER_URL
        
        # add ssh public key for HDFS Master-Worker communication
        cat ~/keys/id_rsa.pub >> ~/.ssh/authorized_keys
        chmod 0600 ~/.ssh/authorized_keys
        rm -rf ~/keys

        # generate localhost key pair for HDFS communcation
        ssh-keygen
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

        # Hadoop configuration: datanode storage, set JAVA_HOME in hadoop-env.sh
        cd ~/usrpylib
        python replace_first_occurance.py $HADOOP_CONF_DIR/hadoop-env.sh 'export JAVA_HOME=${JAVA_HOME}' 'export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-amd64"'
        mkdir -p /home/ubuntu/hadoop_store/hdfs/datanode

        # launch datanode daemon
        $HADOOP_HOME/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
fi

# clean up
cd ~
mv *.sh Utilities