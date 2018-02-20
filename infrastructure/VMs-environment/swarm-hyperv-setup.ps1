# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network") called:
$SwitchName = "virtualPFC"
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesisB\infrastructure\VMs-environment\docker-machine-VMs\swarm-node-hyperv-setup.ps1

# Swarm mode using Docker Machine


# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"

$managers=1
$workers=3

# Current development github branch
$GithubBranch="docker_bind_volumes"

# Pointer to the stack-descriptor file
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis/$GithubBranch/infrastructure/docker-stack.yml"



$fromNow = Get-Date

# create manager machines
echo "======> Creating manager machines ..."
for ($node=1;$node -le $managers;$node++) {
	echo "======> Creating manager$node machine ..."
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName --engine-label danir2.machine.role=manager ('manager'+$node)
}

# create worker machines
echo "======> Creating worker machines ..."
for ($node=1;$node -le $workers;$node++) {
	echo "======> Creating worker$node machine ..."
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName --engine-label danir2.machine.role=worker ('worker'+$node)
}

# list all machines
docker-machine ls
echo "======> Initializing first swarm manager ..."
$manager1ip = docker-machine ip manager1

docker-machine ssh manager1 "docker swarm init --listen-addr $manager1ip --advertise-addr $manager1ip"

# get manager and worker tokens
$managertoken = docker-machine ssh manager1 "docker swarm join-token manager -q"
$workertoken = docker-machine ssh manager1 "docker swarm join-token worker -q"

# other masters join swarm
for ($node=2;$node -le $managers;$node++) {
	echo "======> manager$node joining swarm as manager ..."
	$nodeip = docker-machine ip manager$node
	docker-machine ssh "manager$node" "docker swarm join --token $managertoken --listen-addr $nodeip --advertise-addr $nodeip $manager1ip"
}
# show members of swarm
docker-machine ssh manager1 "docker node ls"

# workers join swarm
for ($node=1;$node -le $workers;$node++) {
	echo "======> worker$node joining swarm as worker ..."
	$nodeip = docker-machine ip worker$node
	docker-machine ssh "worker$node" "docker swarm join --token $workertoken --listen-addr $nodeip --advertise-addr $nodeip $manager1ip"
}

# show members of swarm
docker-machine ssh manager1 "docker node ls"


# Prepare the node manager1:
docker-machine ssh manager1 "mkdir app; mkdir data; mkdir results"

# Get the docker-stack.yml file from github:
docker-machine ssh manager1 "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
docker-machine ssh manager1 "docker stack deploy --compose-file docker-stack.yml $StackName"
# show the service
docker-machine ssh manager1 "docker stack services $StackName"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
echo "======> You can access to the web user interface of the spark master at: $manager1ip :8080"