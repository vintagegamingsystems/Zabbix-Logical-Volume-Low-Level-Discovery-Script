#!/bin/bash
# Author:Joshua Cagle
# Organization: University of Oregon
#
# This script finds the device paths for logical volumes. It is necessary for the zabbix user to
# run this script as the user does not
# have sudo or root access to run the lvdisplay command, which accesses the /dev/mapper/control.
# You do NOT have to enable remote commands or enable unsafe user parameters.
#
# This was tested on Redhat Enterprise 6.
#
# Completely dependent on /dev path. Assumes that devices excluded in grep -v command below will
# be the only directories in the /dev directory.
# Could be fragile and may not scale well if other devices are included on other hosts.
#
declare -a volumeGroups
volumeGroups=$(ls -l /dev | grep "^d" | awk '{print $9}' | grep -v "^block$\|^bsg$\|^char$\|^cpu$\|^disk$\|^hugepages$\|^input$\|^mapper$\|^net$\|^pts$\|^raw$\|^shm$")
# Grep -v find the inverse of the expression. So it will not find the directory block or bsg or...
x=0
y=0
echo "{"
echo "\"data\":["
for vg in ${volumeGroups[@]}
        do
	declare -a lv
        lv=$(ls /dev/$vg)
        # Lists the files within the /dev directory with the $vg variable appended to the end and 
        # places contents within the $lv variable.
        ((x++))
        for multiplelv in ${lv[@]}
        # For volumegroups with multiple logical volumes this for loop with only print those that are needed.
                do
                path=/dev/$vg/$multiplelv
                if [[ "$y" -le "$x" ]]
                then
                echo "{ \"{#LVDEVPATH}\" : \"$path\" },"
                fi
                ((y++))
                done
        done
echo "]"
echo "}"
