#!/bin/env bash
docker build -t wireshark .
docker run -ti --net=host --privileged -v $HOME:/root:ro -e XAUTHORITY=/root/.Xauthority -e DISPLAY=$DISPLAY wireshark
