#!/bin/bash

docker run -d --restart=unless-stopped --network=iuxt -v ./data:/data --name="alist" test
