# EC2 Instance Setup Package Template
**A package to install Spark 3.1, Hadoop 2.7, and Anaconda3-5.3.1 on Ubuntu Server 20.04 LTS**

## Usage Nodes:
- Before transfer to instances for setup, the user must enter the private IP addresses and aliases of all nodes in the cluster in the file *hdfs_config/hosts*. This is necessary for the HDFS setup.

- The same may be done with the *hdfs_config/slaves* file, although it is not used in this current configuration.

- The keys folder contains an rsa keypair used for ssh connection between the Hadoop NameNode and Hadoop DataNodes. It is recommended to generate a new key pair to replace this. If the cluster's security group is open to the internet, an alternative method of key generation should be used, as using the same key for multiple configurations is insecure, as is using a key pair posted on the internet.

- The user may want to edit the Spark logging options in */opt/spark/conf/log4j.properties* to adjust logging reported to the cli.

## Contents:
1. **hdfs_config:** Files used to configure Hadoop and the HDFS.
2. **keys:** An rsa keypair for ssh between Hadoop NameNode and Hadoop DataNode.
3. **usrpylib:** Contains python scripts used to alter configuration files.
4. **environment1, environment2:** */etc/environment* files that will sequentially replace the initial /*etc/environement* file during setup.
5. **name_env.sh:** A script called during setup.sh to prompt the user to label each node as either Master or Worker, and to get the Spark Master URL (*spark://master-private-ip:7077*) so that Spark Worker Nodes can connect to the Spark Master Node on the same EC2 local network.
6. **package_setup.sh:** A script to zip this current setup package and place it in scripts/data, ready for transfer to new instances.
7. **setup.sh:** The main instance setup script that downloads and installs Spark, Hadoop, and Anaconda, and then configures the cluster. This script is to be run using `source setup.sh` instead of launching a child shell process with bash. The same setup.sh script is used to setup both Master and Worker nodes, and the user must choose Master or Worker in cli when setting up each instance. Note that the Master Node must finish setup before the Worker Nodes launch the Spark and Hadoop daemons. setup.sh may be launched at the same time on each instance for time efficiency, however when the user is prompted to choose Master or Worker, the user should only continue and finish the setup on the Master node before allowing the Worker Node setup to continue.
8. **test_cluster.sh:** A script that submits a test PySpark application to a fully setup cluster using spark-submit. The result of this application should be seen in the Spark Master Console, accessed from your local machine (*$MASTER_DNS:8080*).