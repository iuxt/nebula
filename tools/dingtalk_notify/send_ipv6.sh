#!/bin/bash

data=$(ip a | grep "inet6.*global" | awk '{print $2}' | grep -v "^fe80::" )

./dingtalk.py "${data}"
