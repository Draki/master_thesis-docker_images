# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesisB\infrastructure\VMs-environment\docker-machine-VMs\swarm-node-hyperv-teardown.ps1
$fromNow = Get-Date

# $StackName="TheStackOfDani"
# docker-machine ssh manager1 "docker stack rm $StackName"

### Warning: This will remove all docker machines running ###
docker-machine stop (docker-machine ls -q)
docker-machine rm --force (docker-machine ls -q)

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The cleaning took: $timeItTook seconds"