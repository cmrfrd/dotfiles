#!/bin/env bash
docker build -t scapy .
docker run -ti --net=host --privileged -v $HOME:/root:ro scapy
