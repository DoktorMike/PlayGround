#!/bin/bash

# Docker cleanup
docker stop devtest
docker rm devtest
docker volume rm foo

# Create a docker volume pointing to an NFS share
docker volume create --driver local \
      --opt type=nfs \
      --opt o=nfsvers=4,addr=159.89.213.26,rw \
      --opt device=:/ \
      foo

# Mount it into a container
docker run -d \
  --name devtest \
  --mount source=foo,target=/nfs \
  nginx:latest
