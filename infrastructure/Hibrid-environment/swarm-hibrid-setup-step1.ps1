# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network" and
# linked to the interface you will use to access the raspberries), call it with this name:
# $SwitchName = "DockerNAT"
$SwitchName = "virtualPFC"
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-raspi-setup-step1.ps1
# Swarm mode using Docker Machine
$rasPiWorkers = 4

$fromNow = Get-Date

# create manager machine
echo "======> Creating manager machine ..."
docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName manager


# list all machines
docker-machine ls
echo "======> Initializing swarm manager ..."
$managerIp = docker-machine ip manager

docker-machine ssh manager "docker swarm init --listen-addr $managerIp --advertise-addr $managerIp"

# show members of swarm
docker-machine ssh manager "docker node ls"


echo ""
echo ""
echo ">>>>>>> NOW lets make those raspis join the swarm: <<<<<<<<"
echo ""
$workertoken = docker-machine ssh manager "docker swarm join-token worker -q"
$managerIp = docker-machine ip manager
for ($node=1;$node -le $rasPiWorkers;$node++) {
    echo "node$node joining the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@node$node/ -hostkey=*" "call docker swarm join --token $workertoken $managerIp" "exit"
}


# show members of swarm
docker-machine ssh manager "docker node ls"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"