#!/bin/bash
cd $(dirname $0)

docker build . -t cloudreve/cloudreve:latest
