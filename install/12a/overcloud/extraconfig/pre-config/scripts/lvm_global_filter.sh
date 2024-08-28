#!/bin/bash

# https://access.redhat.com/solutions/3213311

sed -e "s/# global_filter = \[ \"a|.*\/|\" \]/global_filter  = [ \"r|.*|\" ]/g" -i /etc/lvm/lvm.conf
pvscan --cache
lvs

exit 0
