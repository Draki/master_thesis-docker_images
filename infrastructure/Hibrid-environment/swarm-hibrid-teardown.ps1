# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesisB\infrastructure\RasPIs-environment\docker-machine-pcmanager-raspis\swarm-raspi-teardown.ps1

$fromNow = Get-Date
$rasPiWorkers = 4
# $StackName="TheStackOfDani"

echo ""
echo ""
echo ">>>>>>> First lets fright those RasPIs out of the swarm: <<<<<<<<"
echo ""

$managerIp = docker-machine ip manager

docker-machine ssh manager "docker node ls" | Select-Object -Property WS -Unique

for ($node=1;$node -le $rasPiWorkers;$node++) {
    echo "node$node leaving the swarm"
    $nodeip = (docker-machine ssh manager "docker node inspect node$node" | ConvertFrom-Json).Status.Addr
    WinSCP.com /command "open sftp://pirate:hypriot@$nodeip/ -hostkey=*" "call docker swarm leave" "exit"
}


# docker-machine ssh manager1 "docker stack rm $StackName"

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The cleaning took: $timeItTook seconds"

### Warning: This will remove all docker machines running ###
docker-machine stop (docker-machine ls -q)
docker-machine rm --force (docker-machine ls -q)