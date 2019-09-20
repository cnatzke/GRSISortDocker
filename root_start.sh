#!/bin/bash 

docker run -it --rm \
    --env="DISPLAY" \
    --net=host \
    --user=$(id -u) \
    --volume="/home/$USER:/home/$USER" \
    --workdir="$PWD" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    cnatzke/root-cern:latest

