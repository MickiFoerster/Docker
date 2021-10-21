#!/bin/sh

docker-compose  up -d 
docker pull hello-world
docker tag hello-world  127.0.0.1:5000/hello-world
docker push 127.0.0.1:5000/hello-world
docker images remove hello-world
docker images remove 127.0.0.1:5000/hello-world
docker pull 127.0.0.1:5000/hello-world
