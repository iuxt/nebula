#!/bin/bash

app=$(basename "$(pwd)")
echo "$app"

/bin/rm -f ../nginx/conf.d/"$app".conf
../nginx/reload.sh
