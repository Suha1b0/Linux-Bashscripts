#!/bin/bash
HNAME=`uname -n`
DT=$(date "+%d-%b-%Y %H:%M:%S")
FLAG=0
MSGM=""
MSGC=""
SUBJ="$DT : $HNAME"

IDLCPU=$(sar -u 3 10 |grep Average|awk '{print $8}'|cut -d. -f1)
MEMUTL=$(sar -r 2 5 |grep Average|awk '{print $4}'|cut -d. -f1)

if [ $IDLCPU -lt 15 ]; then
   MSGC="$MSGC CPU utilization on the system $HNAME is more then 80%, please check below processes \n\n"
   MSGC="$MSGC `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -5` \n\n"
   SUBJ="$SUBJ : HIGH CPU "
   FLAG=1
fi

if [ $MEMUTL -gt 79 ]; then
   MSGM="$MSGM MEMORY utilization on the system $HNAME is more then 80%, please check below processes \n\n"
   MSGM="$MSGM `ps -eo pmem,pcpu,vsize,pid,cmd |grep "%MEM" |grep -v grep` \n"
   MSGM="$MSGM `ps -eo pmem,pcpu,vsize,pid,cmd | sort -k 1 -nr | head -5`"
   SUBJ="$SUBJ : HIGH MEMORY "
   FLAG=1
fi

if [ $FLAG = 1 ]; then
echo -e "Hello All, \nPlease find details below: \n\n$MSGC \n\n $MSGM \n\n\ \n$ORA\n\n nNOTE: THIS IS AN AUTO GENERATED EMAIL, PLEASE DO NOT REPLY TO THIS EMAIL.\n\n\nThank You!!!\nBest Regards\n" |mailx -s "Standard Checks on servers" mohammed.suhaib2@dxc.com
fi
