#!/bin/bash
cd $(dirname $0)

env

/vnts/vnts -U ${USERNAME} -W ${PASSWORD} --white-token ${TOKEN}

