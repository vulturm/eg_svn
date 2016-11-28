#!/bin/bash
docker stop testssh
docker rm testssh
docker rmi test1
docker build -t test1 .
docker run -d -it --name testssh test1
docker exec -it testssh /bin/bash
