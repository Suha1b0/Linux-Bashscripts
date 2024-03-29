#!/bin/bash
# system-chk.sh 
#set -x

if [ -f /usr/sbin/ifconfig ]; then
  IFCONFIG="/usr/sbin/ifconfig"
else
  IFCONFIG="/sbin/ifconfig"
fi
UPTIME=`uptime`
LAST_Reboot=`who -b`
HOSTNAME=`hostname`
DATE=`date +%Y%m%d%H%M`

Logfile=/tmp/"$(date +%Y_%m_%d_%I_%M_%p)_STD_Chk.log"
echo "Running Standard Checks on ${HOSTNAME} ..."
echo "Date: ${DATE}" >>$Logfile
echo "Hostname: ${HOSTNAME}" >>$Logfile
echo "Server Uptime ${UPTIME}" >>$Logfile
echo "Last Reboot ${LAST_Reboot}" >>$Logfile
uname -a >>$Logfile 2>&1
echo "" >>$Logfile
echo "Show top 25 CPU consumers. Based on the outcome validate if these could lead to performance problems." >>$Logfile
ps -eo pid,ppid,state,user,group,pcpu,pmem,vsz,comm --sort -pcpu|head -25 >>$Logfile 2>&1

echo "" >>$Logfile
echo "CPU Utilization sar last 10 seconds. Take actions based on the top 25 processes if the CPU load is constantly High." >>$Logfile
sar -u 1 10 >>$Logfile

echo "" >>$Logfile
echo "Collect GBL_CPU_TOTAL default threshold from Alarmdef" >>$Logfile
grep 'GBL_CPU_TOTAL_UTIL' /var/opt/perf/alarmdef | grep -v '^#' >>$Logfile

echo "" >>$Logfile
echo "Show top 25 Memory consumers. Based on the outcome validate if these could lead to performance problems." >>$Logfile
ps -eo pid,ppid,state,user,group,pcpu,pmem,vsz,comm --sort -pmem|head -25 >>$Logfile 2>&1

echo "" >>$Logfile
echo "Memory Utilization sar" >>$Logfile
sar -r 1 10 >>$Logfile

echo "" >>$Logfile
echo "Memory Report in MB" >>$Logfile
free -m >>$Logfile 2>&1

echo "" >>$Logfile
echo "VMSTAT output. Check if Swapping and or Paging is happening." >>$Logfile
vmstat 1 10 >>$Logfile 2>&1

echo "" >>$Logfile
echo "Collect GBL_MEM_UTIL default threshold from Alarmdef" >>$Logfile
grep 'GBL_MEM_UTIL' /var/opt/perf/alarmdef | grep -v '^#' >>$Logfile

echo "" >>$Logfile
echo "File System Utilization" >>$Logfile
df -ThP|grep Filesystem  >>$Logfile 2>&1
df -ThP|sort -r -nk5|grep -v Filesystem  >>$Logfile 2>&1

echo "" >>$Logfile
echo "Network routing table" >>$Logfile
netstat -rn >>$Logfile 2>&1

echo "" >>$Logfile
echo "Check DNS resolution for ah.nl" >>$Logfile
nslookup ah.nl >>$Logfile 2>&1

echo "" >>$Logfile
echo "Check Network Interfaces" >>$Logfile
#ifconfig -a >>$Logfile 2>&1
$IFCONFIG -a >>$Logfile 2>&1

echo "" >>$Logfile
echo "Show last 20 lines of dmesg output" >>$Logfile
dmesg|tail -20 >>$Logfile 2>&1

echo "" >>$Logfile
TODAY=`date '+%b %d'`
YESTERDAY=`date -d "$TODAY -1 days" '+%b %d'`
echo "grep for Errors and Warnings in messages file" >>$Logfile
cat /var/log/messages|grep "${YESTERDAY}" |egrep -i "error|warn|segfault|fail|denied|segmentation|oops|rejected"|tail -50>>$Logfile 2>&1
cat /var/log/messages|grep "${TODAY}"|egrep -i "error|warn|segfault|fail|denied|segmentation|oops|rejected"|tail -50>>$Logfile 2>&1

echo "" >>$Logfile
echo "Extract last 6 Alarms for last 2 days" >>$Logfile
nr_alarms=`/opt/perf/bin/extract -g -xp -f stdout -b today -2 -e today 2>/dev/null | /bin/cut -d"|" -f21 2>/dev/null | /usr/bin/tail -6|wc -l 2>/dev/null`

echo "${nr_alarms} Alarms reported" >>$Logfile 2>&1

/opt/perf/bin/extract -g -xp -f stdout -b today -2 -e today 2>/dev/null | /bin/cut -d"|" -f21 2>/dev/null | /usr/bin/tail -6 2>/dev/null >>$Logfile

echo -e "\n\nDisk IOS and waits:" >> $Logfile 2>&1
sar -p -d 2 2 |grep ^Average >> $Logfile 2>&1

echo
echo  "Active listening TCP/UDP Ports " >> $Logfile 2>&1
echo -e "netstat -altupn:" >> $Logfile 2>&1
netstat -altupn >> $Logfile 2>&1

echo "Standard Checks on ${HOSTNAME} Completed!"
echo "Check the output!!"
echo "Run cat ${Logfile}|less or check your mail."
