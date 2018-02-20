# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-only_raspi-teardown.ps1

$rasPiManager = "node1"

$fromNow = Get-Date

echo ""
echo ""
echo ">>>>>>> Lets fright those RasPIs out of the swarm: <<<<<<<<"
echo ""

$swarm = WinSCP.com /command "open sftp://pirate:hypriot@$rasPiManager/ -hostkey=*" "call docker node ls" "exit"        # docker-machine ssh manager "docker node ls"

$leader = ($swarm -match "node\d\s+Ready\s+Active(?=\s+Leader)")  -split '\s+' -match 'node.'
$managers = ($swarm -match "node\d\s+Ready\s+Active(?=\s+Reachable)")  -split '\s+' -match 'node.'
$workers = ($swarm -match "node\d\s+Ready\s+Active(?!\s+[Leader|Reachable])")  -split '\s+' -match 'node.'


Foreach ($node in $workers) {
    echo "======>Worker node '$node' leaving the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call docker swarm leave" "exit"
}

Foreach ($node in $managers) {
    echo "======>Manager node '$node' leaving the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call docker swarm leave --force" "exit"
}
echo "======>Leader node '$leader' leaving the swarm"
WinSCP.com /command "open sftp://pirate:hypriot@$leader/ -hostkey=*" "call docker swarm leave --force" "exit"

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The cleaning took: $timeItTook seconds"
