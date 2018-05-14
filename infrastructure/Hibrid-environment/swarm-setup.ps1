# Swarm mode using Docker Machine as manager and RaspberryPis as workers
# Created by: Daniel Rodriguez Rodriguez
#
#
# At the Hyper-V Manager app on Windows, under "ethernet adapter", create a Virtual Switch (as an "external network") called:
$SwitchName = "virtualPFC"
# Run from PowerShell console as Administrator with the command:
#  powershell -executionpolicy bypass -File .\infrastructure\Hibrid-environment\swarm-setup.ps1


# Selecting the right "docker-stack.yml" file
$GithubBranch="master"
$infrastructure="Hibrid"

# Chose a name for the stack, number of manager machines and number of worker machines
$StackName="TheStackOfDani"
$managerZero = "vmNode1"
$rasPiWorkers = @("node1","node2","node3","node4")


## Creating virtual machines...
echo "`n>>>>>>>>>> Creating virtual machines <<<<<<<<<<`n"
$fromNow = Get-Date

# create manager machine
echo "======> Creating manager machine ..."
docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName --hyperv-memory 8192 --hyperv-cpu-count 1 --hyperv-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v18.04.0-ce/boot2docker.iso $managerZero

# list all machines
docker-machine ls


## Creating Docker Swarm...
echo "`n>>>>>>>>>> Building the docker swarm <<<<<<<<<<`n"
echo "======> Initializing first swarm manager ..."
$managerZeroip = docker-machine ip $managerZero

docker-machine ssh $managerZero "docker swarm init --listen-addr $managerZeroip --advertise-addr $managerZeroip"
docker-machine ssh $managerZero "docker node update --label-add role=spark_master --label-add architecture=x86_64 $managerZero"
docker-machine ssh $managerZero "if [ -z `${OWN_IP} ]; then echo export OWN_IP=\'`$(echo `$SSH_CONNECTION | awk '{print `$3; exit}')\' | sudo tee -a /etc/profile; else echo '`$OWN_IP is already set'; fi"



# workers join swarm
# get worker token
$workertoken = docker-machine ssh $managerZero "docker swarm join-token worker -q"


# show members of swarm
docker-machine ssh $managerZero "docker node ls"

echo "$joinAsWorker"
echo "`n`n======> Joining worker raspis to the swarm ...`n"
Foreach ($node in $rasPiWorkers) {
    echo "$node joining the swarm"
    WinSCP.com /command "open sftp://pirate:hypriot@$node/ -hostkey=*" "call if [ -z `${OWN_IP} ]; then echo export OWN_IP=\'`$(echo `$SSH_CONNECTION | awk '{print `$3; exit}')\' | sudo tee -a /etc/profile; else echo '`$OWN_IP is already set'; fi" "call docker swarm join --token $workertoken $managerZeroip" "exit"
    docker-machine ssh $managerZero "docker node update --label-add role=spark_worker --label-add architecture=rpi $node"             # Label Spark workers nodes with their roles
}

# show members of swarm
docker-machine ssh $managerZero "docker node ls"



## Services deployment

# Prepare the node $managerZero:
docker-machine ssh $managerZero "mkdir app; mkdir results; mkdir data"

# Get the docker-stack.yml file from github:
docker-machine ssh $managerZero "wget https://raw.githubusercontent.com/Draki/master_thesis-docker_images/$GithubBranch/infrastructure/$infrastructure-environment/docker-stack.yml --no-check-certificate --output-document docker-stack.yml 2> /dev/null"

# And deploy it:
docker-machine ssh $managerZero "docker stack deploy --compose-file docker-stack.yml --resolve-image never $StackName"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"


echo "docker-machine ssh $managerZero `"docker stack services $StackName`""
echo "======>"
echo "======> You can access to the web user interface of the spark master at:" "${managerZeroip}:8080" ""
echo "======> You can access to the web user interface of the hadoop master at:" "${managerZeroip}:50070" ""

Start-Sleep -s 10
# show the service
echo "docker-machine ssh $managerZero `"docker stack services $StackName`""
docker-machine ssh $managerZero "docker stack services $StackName"

