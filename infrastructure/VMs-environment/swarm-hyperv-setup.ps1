# Swarm mode using Docker Machine
# Created by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network") called:
$SwitchName = "virtualPFC"
# Current development github branch
$GithubBranch="master"
# Pointer to the stack-descriptor file
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/infrastructure/VMs-environment/docker-stack_x86_64.yml"
#
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\VMs-environment\swarm-hyperv-setup.ps1


# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"
$managers = @("vm_node1")
$workers = @("vm_node2","vm_node3","vm_node4")


## Creating virtual machines...
echo "`n>>>>>>>>>> Creating virtual machines <<<<<<<<<<`n"
$fromNow = Get-Date
$managerZero = $managers[0]

# create manager machines
echo "======> Creating manager machines ..."
Foreach ($node in $managers) {
	echo "======> Creating $node machine ..."
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName $node
}

# create worker machines
echo "======> Creating worker machines ..."
Foreach ($node in $workers) {
	echo "======> Creating $node machine ..."
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName $node
}

# list all machines
docker-machine ls



## Creating Docker Swarm...
echo "`n>>>>>>>>>> Building the docker swarm <<<<<<<<<<`n"
echo "======> Initializing first swarm manager ..."
$managerZeroip = docker-machine ip $managerZero

docker-machine ssh $managerZero "docker swarm init --listen-addr $managerZeroip --advertise-addr $managerZeroip"
docker-machine ssh $managerZero "docker node update --label-add role=spark_master --label-add architecture=x86_64 $managerZero"


# other masters join swarm
If ($managers.Length -gt 1) {
    # get manager and worker tokens
    $managertoken = docker-machine ssh $managerZero "docker swarm join-token manager -q"

    Foreach ($node in $managers[1..($managers.Length-1)]) {
        echo "======> $node joining swarm as manager ..."
        $nodeip = docker-machine ip $node
        docker-machine ssh "$node" "docker swarm join --token $managertoken --listen-addr $nodeip --advertise-addr $nodeip $managerZeroip"
        docker-machine ssh $managerZero "docker node update --label-add role=spark_worker --label-add architecture=x86_64 $node"
    }
}


# workers join swarm
# get worker token
$workertoken = docker-machine ssh $managerZero "docker swarm join-token worker -q"

Foreach ($node in $workers) {
	echo "======> $node joining swarm as worker ..."
	$nodeip = docker-machine ip $node
	docker-machine ssh "$node" "docker swarm join --token $workertoken --listen-addr $nodeip --advertise-addr $nodeip $managerZeroip"
	docker-machine ssh $managerZero "docker node update --label-add role=spark_worker --label-add architecture=x86_64 $node"
}

# show members of swarm
docker-machine ssh $managerZero "docker node ls"



## Services deployment

# Prepare the node $managerZero:
docker-machine ssh $managerZero "mkdir app; mkdir data; mkdir results"

# Get the docker-stack.yml file from github:
docker-machine ssh $managerZero "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
docker-machine ssh $managerZero "docker stack deploy --compose-file docker-stack.yml $StackName"
# show the service
docker-machine ssh $managerZero "docker stack services $StackName"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
echo "======> You can access to the web user interface of the spark master at: $managerZeroip :8080"