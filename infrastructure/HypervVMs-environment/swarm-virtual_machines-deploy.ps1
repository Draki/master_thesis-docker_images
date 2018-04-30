# Swarm mode service deployment on Docker Machine cluster
# Created by: Daniel Rodriguez Rodriguez


## Services deployment

# Prepare the node $managerZero:
docker-machine ssh $managerZero "mkdir app; mkdir data; mkdir results"

# Get the docker-stack.yml file from github:
docker-machine ssh $managerZero "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
docker-machine ssh $managerZero "docker stack deploy --compose-file docker-stack.yml $StackName"
# show the service
docker-machine ssh $managerZero "docker stack services $StackName"


echo "======>"
echo "======> You can access to the web user interface of the spark master at: $managerZeroip :8080"