# Swarm mode using Docker Machine as manager and RaspberryPis as workers
# Created by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network") called:
$SwitchName = "virtualPFC"
# Current development github branch
$GithubBranch="master"
# Pointer to the stack-descriptor file
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/infrastructure/Hibrid-environment/docker-stack_hibrid.yml"
#
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\Hibrid-environment\swarm-hibrid-setup.ps1


# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"
$managerZero = "vmNode1"
$rasPiWorkers = @("node1","node2","node3","node4")


## Creating virtual machines...
echo "`n>>>>>>>>>> Creating virtual machines <<<<<<<<<<`n"
$fromNow = Get-Date

# create manager machine
echo "======> Creating manager machine ..."
docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName $managerZero

# list all machines
docker-machine ls



## Creating Docker Swarm...
echo "`n>>>>>>>>>> Building the docker swarm <<<<<<<<<<`n"
echo "======> Initializing first swarm manager ..."
$managerZeroip = docker-machine ip $managerZero

docker-machine ssh $managerZero "docker swarm init --listen-addr $managerZeroip --advertise-addr $managerZeroip"
docker-machine ssh $managerZero "docker node update --label-add role=spark_master --label-add architecture=x86_64 $managerZero"



# workers join swarm
# get worker token
$workertoken = docker-machine ssh $managerZero "docker swarm join-token worker -q"

Foreach ($node in $rasPiWorkers) {
	echo "======> $node joining swarm as worker ..."
	$nodeip = docker-machine ip $node
	docker-machine ssh "$node" "docker swarm join --token $workertoken --listen-addr $nodeip --advertise-addr $nodeip $managerZeroip"
	docker-machine ssh $managerZero "docker node update --label-add role=spark_worker --label-add architecture=x86_64 $node"
}

# show members of swarm
docker-machine ssh $managerZero "docker node ls"

$dockerCommand = @()
echo "$joinAsWorker"
echo "`n`n======> Joining worker raspis to the swarm ...`n"
Foreach ($node in $rasPiWorkers) {
    echo "$node joining the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call docker swarm join --token $workertoken $managerZeroip" "exit"
    docker-machine ssh $managerZero "docker node update --label-add role=spark_worker --label-add architecture=rpi $node"             # Label Spark workers nodes with their roles
}

# show members of swarm
docker-machine ssh $managerZero "docker node ls"



## Services deployment

# Prepare the node $managerZero:
docker-machine ssh $managerZero "mkdir app; mkdir data; mkdir results"

# Get the docker-stack.yml file from github:
docker-machine ssh $managerZero "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
docker-machine ssh $managerZero "docker stack deploy --compose-file docker-stack.yml --resolve-image never $StackName"
# show the service
docker-machine ssh $managerZero "docker stack services $StackName"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
echo "======> You can access to the web user interface of the spark master at: $managerZeroip :8080"