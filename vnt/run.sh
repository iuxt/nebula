#!/bin/bash

docker run --name vnts -d \
    -v ./key:/key \
    -v ./log:/log \
    --network host \
    --privileged \
    --env-file=.env \
    iuxt/vnts:v1.2.12
