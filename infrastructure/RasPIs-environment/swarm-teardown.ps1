# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File .\infrastructure\RasPIs-environment\swarm-teardown.ps1

$fromNow = Get-Date
$rasPiManager = "node1"

echo ""
echo ""
echo ">>>>>>> Lets fright those RasPIs out of the swarm: <<<<<<<<"
echo ""

$StackName="TheStackOfDani"
WinSCP.com /command "open sftp://pirate:hypriot@$rasPiManager/ -hostkey=*" "call docker stack rm $StackName" "exit"


$swarm = WinSCP.com /command "open sftp://pirate:hypriot@$rasPiManager/ -hostkey=*" "call docker node ls" "exit"        # docker-machine ssh manager "docker node ls"

$leader = ($swarm -match "node\d\s+Ready\s+Active(?=\s+Leader)")  -split '\s+' -match 'node.'
$managers = ($swarm -match "node\d\s+Ready\s+Active(?=\s+Reachable)")  -split '\s+' -match 'node.'
$workers = ($swarm -match "node\d\s+Ready\s+Active(?!\s+[Leader|Reachable])")  -split '\s+' -match 'node.'


$dockerCommand = @('call docker swarm leave --force 2> /dev/null', 'call docker stop $(docker ps -a -q) 2> /dev/null', 'call docker rm $(docker ps -a -q) 2> /dev/null', 'call docker rmi $(docker images -q)')

Foreach ($node in $workers) {
    echo "`n`n======>Worker node '$node' leaving the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" $dockerCommand "exit"
}

Foreach ($node in $managers) {
    echo "`n`n======>Manager node '$node' leaving the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" $dockerCommand "exit"
}
echo "`n`n======>Leader node '$leader' leaving the swarm"
WinSCP.com /command "open sftp://pirate:hypriot@$leader/ -hostkey=*" "call rm -R ./*" "exit"
WinSCP.com /command "open sftp://pirate:hypriot@$leader/ -hostkey=*" $dockerCommand "exit"

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "`n`n======>"
echo "======> The cleaning took: $timeItTook seconds"

##!/bin/bash
## Delete all containers
#docker rm $(docker ps -a -q)
## Delete all images
#docker rmi $(docker images -q)