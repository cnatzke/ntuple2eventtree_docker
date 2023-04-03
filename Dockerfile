# Author: C. Natzke
# Creation Date: July 2022
# Update:
# Purpose: Docker container implementation of NTuple2EventTree
#----------------------------------------------------------

#-------------------------------------------
# Build Container
#-------------------------------------------
FROM opensciencegrid/osgvo-ubuntu-20.04:latest

SHELL ["/bin/bash", "-c"]

RUN mkdir /software

#-------------------------------------------------------------------------------
# ROOT Install
#-------------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install --no-install-recommends -yy  \
    build-essential \
    dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev python libssl-dev && \
    rm -rf /var/lib/apt/lists/*


RUN wget https://root.cern/download/root_v6.26.04.Linux-ubuntu20-x86_64-gcc9.4.tar.gz --output-document /var/tmp/root.tar.gz && \
    tar zxf /var/tmp/root.tar.gz -C /software && \
    rm /var/tmp/root.tar.gz

#-------------------------------------------------------------------------------
# GRSISort Build
#-------------------------------------------------------------------------------
WORKDIR /software

RUN git clone https://github.com/GRIFFINCollaboration/GRSISort.git && \
    source /software/root/bin/thisroot.sh &&\
    cd GRSISort && make 

RUN cd GRSISort && \
    git clone https://github.com/GRIFFINCollaboration/GRSIData.git && \
    cd GRSIData && \
    source /software/root/bin/thisroot.sh &&\
    source /software/GRSISort/thisgrsi.sh &&\
    make

# remove comment character in .grsirc
RUN sed -ie '$s/^.//' ./GRSISort/.grsirc

#-------------------------------------------------------------------------------
# CommandLinesTools Build
#-------------------------------------------------------------------------------
WORKDIR /software

RUN git clone https://github.com/GRIFFINCollaboration/CommandLineInterface.git && \
    cd CommandLineInterface && \
    mkdir build && cd build && \
    source /software/root/bin/thisroot.sh &&\
    source /software/GRSISort/thisgrsi.sh &&\
    cmake -DCMAKE_INSTALL_PREFIX=/software/CommandLineInterface .. &&\
    make install

# setting proper environment variables
ENV LD_LIBRARY_PATH /software/CommandLineInterface/lib:/software/CommandLineInterface

#-------------------------------------------------------------------------------
# Ntuple2EventTree Build
#-------------------------------------------------------------------------------
WORKDIR /software

RUN git clone https://github.com/GRIFFINCollaboration/NTuple2EventTree.git

COPY Makefile /software/NTuple2EventTree

RUN source /software/root/bin/thisroot.sh &&\
    source /software/GRSISort/thisgrsi.sh &&\
    cd NTuple2EventTree &&\
    make 

#-------------------------------------------------------------------------------
# SortAnalysisTree Build
#-------------------------------------------------------------------------------
WORKDIR /software

RUN pwd
RUN git clone https://github.com/cnatzke/sort-analysis-trees.git && \
    source /software/root/bin/thisroot.sh && \
    source /software/GRSISort/thisgrsi.sh && \
    cd sort-analysis-trees && \
    git checkout osg-deployment && \
    mkdir build && cd build && \
    cmake ../ && \
    make