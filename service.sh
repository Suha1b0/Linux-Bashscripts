if [[ `cat /etc/redhat-release | awk '{print $7}'` == 6.1 ]]; then service mdatp restart; echo "service has been restarted for RHEL 6"; else systemctl restart mdatp; echo "service has been restarted for RHEL 7"; fi
