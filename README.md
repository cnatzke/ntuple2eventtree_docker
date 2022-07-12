# Getting Started
This is a containerized version of the GRIFFIN collaboration _NTuple2EventTree_ code used for two-photon emission studies. 

## Building 
To build the docker image, run the below command:
```
docker build --tag <tag> .
```
in the directory containing the files `Dockerfile`

## Running 
To run the container as root user:
```
docker run -it --rm=true cnatzke/ntuple2eventtree_2photon:latest
```
To run similar to the OSG implementation (recommended)
```
docker run --user $(id -u):$(id -g) --rm=true -it -v $(pwd):/scratch -w
/scratch cnatzke/ntuple2eventtree:latest /bin/bash 
```
