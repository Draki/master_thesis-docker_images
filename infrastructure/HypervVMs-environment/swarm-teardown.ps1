# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File .\infrastructure\HypervVMs-environment\swarm-teardown.ps1

$fromNow = Get-Date

# $StackName="TheStackOfDani"
# docker-machine ssh node1 "docker stack rm $StackName"

### Warning: This will remove all docker machines running ###
docker-machine stop (docker-machine ls -q)
docker-machine rm --force (docker-machine ls -q)

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The cleaning took: $timeItTook seconds"