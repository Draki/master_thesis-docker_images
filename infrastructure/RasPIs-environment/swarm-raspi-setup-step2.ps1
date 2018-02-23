# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network") called:
$SwitchName = "DockerNAT"
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesisB\infrastructure\RasPIs-environment\docker-machine-pcmanager-raspis\swarm-raspi-setup-step2.ps1
# Swarm mode using raspberryPIes


# Current development github branch
$GithubBranch="infrastructure_deployment"

# Pointer to the stack-descriptor file
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/docker-stack_rpi.yml"




$rasPiManagers = @("node1")
$managerZero = $rasPiManagers[0]

# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"





WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call docker node ls" "exit"


$fromNow = Get-Date

# list all machines
docker-machine ls

# show members of swarm
$dockerCommand = "docker node ls"
WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call $dockerCommand" "exit"


# Prepare the node manager:
$dockerCommand = "mkdir app; mkdir data; mkdir results"

# Get the docker-stack.yml file from github:
$dockerCommand2 = "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
$dockerCommand3 = "docker stack deploy --compose-file docker-stack.yml $StackName"

# show the service
$dockerCommand4 = "docker stack services $StackName"

WinSCP.com /command "open sftp://pirate:hypriot@$managerZero/ -hostkey=*" "call $dockerCommand1" "call $dockerCommand2" "call $dockerCommand3" "call $dockerCommand4" "exit"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
$managerIp = docker-machine ip manager
echo "======> You can access to the web user interface of the spark master at: $managerIp :8080"