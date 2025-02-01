#!/bin/bash

if [ "$(podman network ls | grep -c iuxt)" -eq 0 ]; then
  podman network create iuxt
else
  echo "podman network iuxt exists skip"
fi

