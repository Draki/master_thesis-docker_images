# Swarm mode infrastructure building using Docker Machine and Hyper-V
# Created by: Daniel Rodriguez Rodriguez

$SwitchName = "virtualPFC"
$manager = "vmManager"
$workers = @("vmWorker1","vmWorker2","vmWorker3")

docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName $manager
$managerIp = docker-machine ip $manager
docker-machine ssh $manager "docker swarm init --advertise-addr $managerIp"

$workertoken = docker-machine ssh $manager "docker swarm join-token worker -q"
Foreach ($node in $workers) {
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName $node
	docker-machine ssh "$node" "docker swarm join --token $workertoken $managerIp"
}

docker-machine ssh $manager "docker node ls"

