#!/bin/bash

jail_list=$(fail2ban-client status | grep "Jail list" | awk -F ":" '{print $2}' | xargs | sed 's/,//g')

for i in ${jail_list[*]};
do
    fail2ban-client status "$i"
done

