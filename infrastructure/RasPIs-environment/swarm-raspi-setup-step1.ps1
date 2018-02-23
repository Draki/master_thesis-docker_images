# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network" and
# linked to the interface you will use to access the raspberries), call it with this name:
$SwitchName = "DockerNAT"
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-only_raspi-setup-step1.ps1
# Swarm mode using Donly RaspberryPIes

$rasPiManagers = @("node1")
$rasPiWorkers = @("node2","node3","node4")


$fromNow = Get-Date
$managerZero = $rasPiManagers[0]

echo "======> Initializing the original swarm manager in node1 ..."         # And storing the command to join as a worker node
$joinAsWorker = (WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call docker swarm init" "exit" | Select-String -Pattern 'docker swarm join --token').Line.trim()
$labels = """call docker node update --label-add role=spark_master node1"""

# In case we got additional managers:
If ($rasPiManagers.Length -gt 1) {
    echo "======> Joining additional managers ..."
    $managertoken = WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call docker swarm join-token manager -q" "exit" | Select -Last 1
    $joinAsManager = $joinAsWorker -replace '(?<=token\s)(.*?)(?=\s192\.168\.1\.\d+\:\d+)', $managertoken

    Foreach ($node in $rasPiManagers[1..($rasPiManagers.Length-1)]) {
        echo "Master node '$node' joining the swarm"
        WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call $joinAsManager" "exit"
        $labels += " ""call docker node update --label-add role=spark_worker $node"""
    }
}


echo "$joinAsWorker"
echo "`n======> Joining worker raspis to the swarm ...`n"
Foreach ($node in $rasPiWorkers) {
    echo "$node joining the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call $joinAsWorker" "exit"
    $labels += " ""call docker node update --label-add role=spark_worker $node"""
}

# Label all nodes with their roles
echo "======> Labeling each node with their role ..."
WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" $labels "exit"

# show members of swarm
WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call docker node ls" "exit"

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"