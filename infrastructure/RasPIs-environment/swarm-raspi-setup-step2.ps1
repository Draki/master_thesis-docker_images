# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network") called:
$SwitchName = "DockerNAT"
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesisB\infrastructure\RasPIs-environment\docker-machine-pcmanager-raspis\swarm-raspi-setup-step2.ps1
# Swarm mode using Docker Machine


# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"

# Current development github branch
$GithubBranch="docker_bind_volumes"

# Pointer to the stack-descriptor file
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis/$GithubBranch/infrastructure/docker-stack.yml"



$fromNow = Get-Date

# list all machines
docker-machine ls

# show members of swarm
docker-machine ssh manager "docker node ls"

# Prepare the node manager:
docker-machine ssh manager "mkdir app; mkdir data; mkdir results"

# Get the docker-stack.yml file from github:
docker-machine ssh manager "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
docker-machine ssh manager "docker stack deploy --compose-file docker-stack.yml $StackName"
# show the service
docker-machine ssh manager "docker stack services $StackName"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"

echo "======>"
$managerIp = docker-machine ip manager
echo "======> You can access to the web user interface of the spark master at: $managerIp :8080"