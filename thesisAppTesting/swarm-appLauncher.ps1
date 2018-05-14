# Swarm mode using Docker Machine as manager and RaspberryPis as workers
# Created by: Daniel Rodriguez Rodriguez
#
#  powershell -executionpolicy bypass -File .\thesisAppTesting\swarm-appLauncher.ps1
##

$application = "thesisapp_0.9.1.jar"
$data = "DelightingCustomersBDextract2Formatted.json"
$sampleApplicationConfigs = @("commons","dataExplorer_sample","dataExplorer_sample2","recommenderALS_sample","recommenderGraphD_sample")

$GithubBranch="master"

$managerZero="vmNode1"
$services = docker-machine ssh $managerZero "docker ps -a"
$hadoopContainer = ($services -match "^[\S]+(?=[\s]+sequenceiq\/hadoop-docker)" -split '\s+')[0]
$sparkContainer = ($services -match "^[\S]+(?=[\s]+danielrodriguez\/docker-spark)" -split '\s+')[0]

docker-machine ssh $managerZero "docker exec $hadoopContainer /usr/local/hadoop/bin/hdfs dfsadmin -safemode leave"
Start-Sleep -s 15
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -mkdir hdfs://hadoop-master:9000/data"
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -mkdir hdfs://hadoop-master:9000/results"

docker-machine ssh $managerZero "wget https://raw.githubusercontent.com/Draki/master_thesis-app/master/configExamples/$data --no-check-certificate --output-document ./data/$data 2> /dev/null"
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -put data/$data hdfs://hadoop-master:9000/data/"
docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -ls hdfs://hadoop-master:9000/data/"

docker-machine ssh $managerZero "wget https://github.com/Draki/master_thesis-app/releases/download/app/$application --no-check-certificate --output-document ./app/$application 2> /dev/null"
$appConfigs = ""
Foreach ($sample in $sampleApplicationConfigs){
    docker-machine ssh $managerZero "wget https://raw.githubusercontent.com/Draki/master_thesis-app/master/configExamples/$sample --no-check-certificate --output-document ./app/$sample 2> /dev/null"
    $appConfigs += '"./app/' + $sample + '" '
}

docker-machine ssh $managerZero ""docker exec $sparkContainer spark-submit --class "thesisApp.ThesisAppLauncher" --deploy-mode client --master spark://spark-master:7077 --executor-memory 650m ./app/$application "hibrid" $appConfigs ""
#docker-machine ssh $managerZero ""docker exec $sparkContainer spark-submit --class "thesisApp.ThesisAppLauncher" --deploy-mode client --master spark://spark-master:7077 --executor-memory 4g ./app/$application "hyperv" $appConfigs ""

echo ""docker-machine ssh $managerZero "docker exec $sparkContainer /usr/hadoop-2.7.1/bin/hdfs dfs -cat hdfs://hadoop-master:9000/results/DelightingCustomersBDextract2Formatted/<date_log>/timeLog.json" ""