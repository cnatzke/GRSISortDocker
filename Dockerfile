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
      org.label-schema.name="ROOT ${VERSION_ROOT} python3 GRSISort ${VERSION_GRSI}" \
      org.label-schema.description="Compiled ROOT python3 GRSISort environment" \
      org.label-schema.url="https://github.com/cnatzke/GRSISortDocker" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.VCS_URL=$VCS_URL \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

#LABEL description="Framework for running GRSISort across different environments"
#LABEL version="0.1.0"

SHELL ["/bin/bash", "-c"]

# Install dependencies and python
RUN apt-get update && apt-get install -y \
    python3 python3-dev python3-pip \
    git dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev \
    libxft-dev libxext-dev libpng-dev libjpeg-dev \
    sudo wget curl \
    # optional ROOT libraries
    gfortran libssl-dev libpcre3-dev \
    xlibmesa-glu-dev libglew1.5-dev libftgl-dev \
    libmysqlclient-dev libfftw3-dev libcfitsio-dev \
    graphviz-dev libavahi-compat-libdnssd-dev \
    libldap2-dev libxml2-dev libkrb5-dev \
    libgsl0-dev libqt4-dev && \ 
    # clean up
    rm -rf /var/lib/apt/lists/* && \
    pip3 install --upgrade pip setuptools && \
    # make some useful symlinks that are expected to exist
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    if [[ ! -e /usr/bin/python-config ]]; then ln -sf /usr/bin/python3-config /usr/bin/python-config; fi && \
    if [[ ! -e /usr/bin/pip ]]; then ln -sf /usr/bin/pip3 /usr/bin/pip; fi
 
################################################################################ 
# ROOT BUILD
################################################################################ 
# download and install ROOT
WORKDIR /root
RUN wget https://root.cern.ch/download/root_v${VERSION_ROOT}.source.tar.gz  && \
    tar xvfz root_v${VERSION_ROOT}.source.tar.gz && \
    mkdir /opt/root && \
    cd /opt/root && \ 
    # ROOT build options
    cmake ${HOME}/root-${VERSION_ROOT}/ \
      -Dpython3=ON \
      -DPYTHON_EXECUTABLE:FILEPATH="/usr/bin/python3" \
      -DPYTHON_INCLUDE_DIR:PATH="/usr/include/python3.6m" \
      -DPYTHON_INCLUDE_DIR2:PATH="/usr/include/x86_64-linux-gnu/python3.6m" \
      -DPYTHON_LIBRARY:FILEPATH="/usr/lib/x86_64-linux-gnu/libpython3.6m.so" \
      -Dminuit2=ON \
      -Dxml=ON \
      -Dmathmore=ON && \
    cmake --build . -- -j5 && \
    rm -r ${HOME}/root-${VERSION_ROOT}/ && ${HOME}/root_v${VERSION_ROOT}.source.tar.gz

# Create ROOT user 
RUN groupadd -g 1000 rootusr && \
    adduser --disabled-password --gecos "" -u 1000 --gid 1000 rootusr && \
    echo "rootusr ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers

USER rootusr
WORKDIR /home/rootusr
ENV HOME /home/rootusr
ADD pythonrc.py $HOME/.pythonrc.py
ADD bashrc      $HOME/.bashrc
ADD bashrc      $HOME/.zshrc
ADD entrypoint.sh /opt/root/entrypoint.sh
RUN sudo chmod 755 /opt/root/entrypoint.sh

ENTRYPOINT [ "/opt/root/entrypoint.sh"]
CMD        [ "/bin/zsh"]
