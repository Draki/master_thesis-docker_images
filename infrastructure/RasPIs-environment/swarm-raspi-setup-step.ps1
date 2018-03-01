# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-raspi-setup-step.ps1
# Swarm mode using Donly RaspberryPIes

# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"
$rasPiManagers = @("node1")
$rasPiWorkers = @("node2","node3","node4")




# Current development github branch
$GithubBranch="infrastructure_deployment"

# Pointer to the stack-descriptor filepowershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-raspi-setup-step2.ps1
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/docker-stack_rpi.yml"



$fromNow = Get-Date
$managerZero = $rasPiManagers[0]

echo "`n`n======> Initializing the original swarm manager in node1 ..."         # And storing the command to join as a worker node
$joinAsWorker = (WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call docker swarm init" "exit" | Select-String -Pattern 'docker swarm join --token').Line.trim()
$dockerCommand = @("docker node update --label-add role=spark_master --label-add architecture=rpi node1")               # Label Spark master node with its role

# In case we got additional managers:
If ($rasPiManagers.Length -gt 1) {
    echo "`n`n======> Joining additional managers ..."
    $managertoken = WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call docker swarm join-token manager -q" "exit" | Select -Last 1
    $joinAsManager = $joinAsWorker -replace '(?<=token\s)(.*?)(?=\s192\.168\.1\.\d+\:\d+)', $managertoken

    Foreach ($node in $rasPiManagers[1..($rasPiManagers.Length-1)]) {
        echo "`nMaster node '$node' joining the swarm"
        WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call $joinAsManager" "exit"
        $dockerCommand += "docker node update --label-add role=spark_worker --label-add architecture=rpi $node"         # Label Spark workers nodes with their roles
    }
}


echo "$joinAsWorker"
echo "`n`n======> Joining worker raspis to the swarm ...`n"
Foreach ($node in $rasPiWorkers) {
    echo "$node joining the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call $joinAsWorker" "exit"
    $dockerCommand += "docker node update --label-add role=spark_worker --label-add architecture=rpi $node"             # Label Spark workers nodes with their roles
}

# Label all nodes with their roles

# show members of swarm
$dockerCommand += "docker node ls"


for ($i=0; $i -lt $dockerCommand.Count; $i++) {
    $dockerCommand[$i] = "call " + $dockerCommand[$i]
}
WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" $dockerCommand "exit"



# Prepare the node manager:
$dockerCommand = @("mkdir app; mkdir data; mkdir results")

# Get the docker-stack.yml file from github:
$dockerCommand += "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml 2> /dev/null"

# And deploy it:
$dockerCommand += "docker stack deploy --compose-file docker-stack.yml --resolve-image never $StackName"

# show the service
$dockerCommand += "docker stack services $StackName"


for ($i=0; $i -lt $dockerCommand.Count; $i++) {
    $dockerCommand[$i] = "call " + $dockerCommand[$i]
}
WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" $dockerCommand "exit"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "`n`n======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
echo "======> In a couple of minutes you will be able to access to the web user interface of the spark master at: $managerZero :8080"