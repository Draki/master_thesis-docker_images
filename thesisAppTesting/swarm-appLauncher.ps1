# Swarm mode using Docker Machine as manager and RaspberryPis as workers
# Created by: Daniel Rodriguez Rodriguez
# requires to have "thesisapp_2.11-1.0.jar" "dataExplorer_sample" and "dataExplorer_sample2"
# in "app" folder on the spark-master container
#
#  powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-appLauncher.ps1
##

# Get the docker-stack.yml file from github:
docker-machine ssh $managerZero "wget https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/infrastructure/$infrastructure-environment/docker-stack.yml --no-check-certificate --output-document docker-stack.yml 2> /dev/null"

$data = "DelightingCustomersBDextract2Formatted.json"
$sampleApplicationConfigs = @("dataExplorer_sample","dataExplorer_sample2","recommenderALS_sample","recommenderGraphD_sample")
$application = "thesisapp_beta_0.8.jar"


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

docker-machine ssh $managerZero "wget https://github.com/Draki/master_thesis-app/releases/download/hibridEnvReady/$application --no-check-certificate --output-document ./app/$application 2> /dev/null"
$appConfigs = ""
Foreach ($sample in $sampleApplicationConfigs){
    docker-machine ssh $managerZero "wget https://raw.githubusercontent.com/Draki/master_thesis-app/master/configExamples/$sample --no-check-certificate --output-document ./app/$sample 2> /dev/null"
    $appConfigs += '"' + $sample + '" '
}

docker-machine ssh $managerZero ""docker exec $sparkContainer spark-submit --class "thesisApp.ThesisAppLauncher" --deploy-mode client --master spark://spark-master:7077 --executor-memory 650m ./app/$application "hdfs://hadoop-master:9000" "/data/" "DelightingCustomersBDextract2Formatted.json" "/results/" $appConfigs ""