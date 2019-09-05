################################################################################
# author: Connor Natzke
# date: Sept. 2019
# purpose: Multi-stage docker file for GRSISort and ROOT
# based on clelange/cern-root-python3-docker-ubuntu
################################################################################ 

################################################################################ 
# BUILD CONTAINER
################################################################################ 

FROM ubuntu:18.10 AS BUILDER 

# versions of installed software
ARG VERSION_ROOT="6.14.06"
ARG VERSION_GRSI="4.0.0"

# labeling information
LABEL maintainer="Connor Natzke <cnatzke@triumf.ca>"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="ROOT ${VERSION_ROOT} python3 GRSISort ${VERSION_GRSI}"
      org.label-schema.description="Compiled ROOT python3 GRSISort environment"
      org.label-schema.url=
      org.label-schema
      org.label-schema
      org.label-schema
      org.label-schema
      org.label-schema

LABEL description="Framework for running GRSISort across different environments"
LABEL version="0.1.0"

RUN apt-get update && apt-get install -y \
    git dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev \
    libxft-dev libxext-dev wget
# install basic libraries
RUN apt-get install -y \
    gfortran libssl-dev libpcre3-dev \
    xlibmesa-glu-dev libglew1.5-dev libftgl-dev \
    libmysqlclient-dev libfftw3-dev libcfitsio-dev \
    graphviz-dev libavahi-compat-libdnssd-dev \
    libldap2-dev python-dev libxml2-dev libkrb5-dev \
    libgsl0-dev libqt4-dev
    
################################################################################ 
# ROOT BUILD
################################################################################ 
# download and build ROOT
RUN mkdir /softwares && cd /softwares && mkdir buildroot && \
    wget https://root.cern.ch/download/root_v${VERSION_ROOT}.source.tar.gz  && \
    tar xvf root_v${VERSION_ROOT}.source.tar.gz  
    
RUN cd /softwares/buildroot && cmake \
      -DCMAKE_INSTALL_PREFIX=/softwares/root \ 
      -Dminuit2=ON -Dxml=ON \
      -Dmathmore=ON \
      ../root-6.14.06 && \ 
    cmake --build . -- -j5 && \
    make install

# set ROOT environment
ENV ROOTSYS "/software/root"
ENV PATH "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH "$ROOTSYS/lib:$PYTHONPATH"

