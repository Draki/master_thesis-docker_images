# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-teardown.ps1

$fromNow = Get-Date
$manager = "vmNode1"
#$rasPiWorkers = 4


$StackName="TheStackOfDani"
docker-machine ssh $manager "docker stack rm $StackName"
#docker stop $(docker ps -a -q)
#docker rm $(docker ps -a -q)

echo ""
echo ""
echo ">>>>>>> First lets fright those RasPIs out of the swarm: <<<<<<<<"
echo ""

#docker-machine ssh $manager "docker node ls" | Select-Object -Property WS -Unique
#for ($node=1;$node -le $rasPiWorkers;$node++) {
#    echo "node$node leaving the swarm"
#    $nodeip = (docker-machine ssh $manager "docker node inspect node$node" | ConvertFrom-Json).Status.Addr
#    WinSCP.com /command "open sftp://pirate:hypriot@$nodeip/ -hostkey=*" "call docker swarm leave" "exit"
#}

$swarm = docker-machine ssh $manager "docker node ls"
$workers = ($swarm -match "node\d\s+Ready\s+Active(?!\s+[Leader|Reachable])")  -split '\s+' -match 'node.'
Foreach ($node in $workers) {
    echo "`n`n======>Worker node '$node' leaving the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call docker swarm leave" "exit"
}

#docker-machine ssh $manager "docker swarm leave --force"
docker-machine stop $manager
docker-machine rm --force $manager


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The cleaning took: $timeItTook seconds"
