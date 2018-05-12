# Swarm mode using Docker Machine as manager and RaspberryPis as workers
# Created by: Daniel Rodriguez Rodriguez
# requires to have "thesisapp_2.11-1.0.jar" "dataExplorer_sample" and "dataExplorer_sample2"
# in "app" folder on the spark-master container
#
#  powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-appLauncher.ps1
##

$managerZero="vmNode1"
$services = docker-machine ssh $managerZero "docker ps -a"
$hadoopContainer = ($services -match "^[\S]+(?=[\s]+sequenceiq\/hadoop-docker)" -split '\s+')[0]
docker-machine ssh $managerZero "docker exec $hadoopContainer /usr/local/hadoop/bin/hdfs dfs -mkdir /data"
docker-machine ssh $managerZero "docker exec $hadoopContainer /usr/local/hadoop/bin/hdfs dfs -mkdir /results"
docker-machine ssh $managerZero "docker exec $hadoopContainer /usr/local/hadoop/bin/hdfs dfs -put /usr/local/hadoop/data/DelightingCustomersBDextract2.json /data"


$sparkContainer = ($services -match "^[\S]+(?=[\s]+danielrodriguez\/docker-spark)" -split '\s+')[0]
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -ls hdfs://hadoop:9000/data/"
docker-machine ssh $managerZero """docker exec $sparkContainer spark-submit --class "thesisApp.ThesisAppLauncher" --deploy-mode client --master spark://spark-master:7077 app/thesisapp_2.11-1.0.jar "hdfs://hadoop:9000" "/data/" "DelightingCustomersBDextract2.json" "/results/" "app/dataExplorer_sample" "app/dataExplorer_sample2" """

