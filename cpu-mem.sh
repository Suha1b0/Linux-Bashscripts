#!/bin/bash
HNAME=`uname -n`
DT=$(date "+%d-%b-%Y %H:%M:%S")
FLAG=0
IDLCPU=""
MEMUTL=""
SUBJ="$DT : $HNAME"

IDLCPU=$(sar -u 3 10 |grep Average|awk '{print $8}'|cut -d. -f1)
MEMUTL=$(sar -r 2 5 |grep Average|awk '{print $4}'|cut -d. -f1)

echo -e "Hello All, \nPlease find details below: \n\n Average CPU idle% is $IDLCPU  \n\n Average MEM consumed % is $MEMUTL \n\n\  nNOTE: THIS IS AN AUTO GENERATED EMAIL, PLEASE DO NOT REPLY TO THIS EMAIL.\n\n\nThank You!!!\nBest Regards\n" |mailx -s "Standard Checks on servers" mohammed.suhaib2@dxc.com
