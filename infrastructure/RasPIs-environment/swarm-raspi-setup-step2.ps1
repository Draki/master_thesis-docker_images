# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# Swarm mode using raspberryPIes
#
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-raspi-setup-step2.ps1



# Current development github branch
$GithubBranch="infrastructure_deployment"

# Pointer to the stack-descriptor filepowershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesis-docker_images\infrastructure\RasPIs-environment\swarm-raspi-setup-step2.ps1
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/docker-stack_rpi.yml"




$rasPiManagers = @("node1")
$managerZero = $rasPiManagers[0]

# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"



$fromNow = Get-Date


# show members of swarm
$dockerCommand = @("docker node ls")


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
echo "======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
echo "======> You can access to the web user interface of the spark master at: ($managerZero):8080"