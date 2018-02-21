DOCKER_IMAGE_VERSION=jdk-1.8.131_hadoop-2.7.3_spark-2.2.1
DOCKER_IMAGE_NAME=danielrodriguez/docker-spark-raspbian
DOCKER_IMAGE_TAGNAME=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

default: build

build:
	docker build -t $(DOCKER_IMAGE_TAGNAME) .

push:
	docker tag $(DOCKER_IMAGE_TAGNAME) $(DOCKER_IMAGE_NAME):latest
	docker push $(DOCKER_IMAGE_TAGNAME)
	docker push $(DOCKER_IMAGE_NAME)

test:
    docker run --rm $(DOCKER_IMAGE_TAGNAME) /bin/echo "Success."

version:
	docker run --rm $(DOCKER_IMAGE_TAGNAME) java -version
    docker run --rm danielrodriguez/docker-spark-raspbian spark-shell --version