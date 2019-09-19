#!/bin/bash 

    #--hostname="root_container" \
    #--user=$(id -u) \
    #--volume="/etc/group:/etc/group:ro" \
    #--volume="/etc/passwd:/etc/passwd:ro" \
    #--volume="/etc/shadow:/etc/shadow:ro" \
    #--volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    
docker run -it --rm \
    --env="DISPLAY" \
    --hostname="root_container" \
    --user=$(id -u) \
    --workdir="/home/$USER" \
    --volume="/home/$USER:/home/$USER" \
    --volume="/etc/group:/etc/group:ro" \
    --volume="/etc/passwd:/etc/passwd:ro" \
    --volume="/etc/shadow:/etc/shadow:ro" \
    --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    cnatzke/root-cern:latest

# sudo apt update && sudo apt install -y x11-apps
