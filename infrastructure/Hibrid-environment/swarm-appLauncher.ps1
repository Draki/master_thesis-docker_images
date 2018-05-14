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
$sparkContainer = ($services -match "^[\S]+(?=[\s]+danielrodriguez\/docker-spark)" -split '\s+')[0]

docker-machine ssh $managerZero "docker exec $hadoopContainer /usr/local/hadoop/bin/hdfs dfsadmin -safemode leave"
Start-Sleep -s 15
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -mkdir hdfs://hadoop-master:9000/data"
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -mkdir hdfs://hadoop-master:9000/results"
Start-Sleep -s 5
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -put app/DelightingCustomersBDextract2Formatted.json hdfs://hadoop-master:9000/data/"
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -ls hdfs://hadoop-master:9000/data/"


docker-machine ssh $managerZero """docker exec $sparkContainer spark-submit --class "thesisApp.ThesisAppLauncher" --deploy-mode client --master spark://spark-master:7077 --executor-memory 650m app/thesisapp_2.11-1.0.jar "hdfs://hadoop-master:9000" "/data/" "DelightingCustomersBDextract2Formatted.json" "/results/" "app/dataExplorer_sample" "app/recommenderALS_sample" "app/recommenderGraphD_sample" """