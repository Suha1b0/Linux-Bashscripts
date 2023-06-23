#!/bin/bash

OSREL=$(cat /etc/redhat-release |cut -d' ' -f7|cut -d. -f1)
HNAME=$(uname -n)
MSG="Memory usage, Swap usage, CPU usage and Filesystem usage details on system $HNAME : "
MSG1="$HNAME,"

### Getting memory/swap usage
chkmem() {
 MEMTOT=$(free -m |grep ^Mem|awk '{printf $2}')
 MEMFRE=$(free -m |grep ^Mem|awk '{printf $4}')
 #MEMFREP=$((MEMFRE/MEMTOT*100))
 MEMFREP=$(echo "$MEMFRE/$MEMTOT*100" |bc -l|cut -c1-5)
 SWPTOT=$(free -m |grep ^Swap|awk '{printf $2}')
 SWPFRE=$(free -m |grep ^Swap|awk '{printf $4}')
 SWPFREP=$(echo "$SWPFRE/$SWPTOT*100" |bc -l|cut -c1-5)
 MSG1="$MSG1 MEM-TOTAL=$MEMTOT, MEM-FREE=$MEMFREP%, SWAP-TOTAL=$SWPTOT, SWAP-FREE=$SWPFREP%, "
}

### Getting cpu usage
chkcpu() {
 USRCPU=$(top -b -n1 |grep ^Cpu |awk '{print $2}'|cut -d',' -f1)
 SYSCPU=$(top -b -n1 |grep ^Cpu |awk '{print $3}'|cut -d',' -f1)
 IDLCPU=$(top -b -n1 |grep ^Cpu |awk '{print $5}'|cut -d',' -f1)
 MSG1="$MSG1 USER-CPU=$USRCPU, SYSTEM-CPU=$SYSCPU, IDLE-CPU=$IDLCPU, "
}

### Getting Filesystem usage
chkfs() {
  df -ThP |grep -v ^Filesystem > /tmp/dfout
  FSCHECK=0
  MSG1="$MSG1 FILESYSTEM-USAGE: "
  MSGX=" "
  while read line ; do
    FS=$(echo $line|awk '{print $7}')
    FSUSE=$(echo $line |awk '{print $6}'|cut -d'%' -f1)
    if [ $FSUSE -gt 79 ]; then
      MSGX="$MSGX $FS = $FSUSE%, "
      FSCHECK=1
    fi
  done</tmp/dfout
  if [ $FSCHECK = 0 ]; then
    MSGX="$MSGX None FS are over 80 % "
  fi
  MSG1="$MSG1 $MSGX  "
  rm -f /tmp/dfout
}

##### MAIN PART FO TEH PROGRAM #####
chkmem
chkcpu
chkfs
mkdir -p /home/pnl/peak-season
PSFILE="/home/pnl/peak-season/$HNAME.txt"
chown -R pnl:users /home/pnl/peak-season
chmod 777 $PSFILE
echo -e "$MSG" > $PSFILE
echo -e "$MSG1" >> $PSFILE

exit 0



