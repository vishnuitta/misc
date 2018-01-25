#!/bin/bash

jenkins=`kubectl get pods | grep jenkins | awk '{print $3}'`
cstor=`kubectl get pods | grep ctrl | awk '{print $3}'`


if [ "$jenkins" = "" ]; then
	echo "jenkins              Not Running"
else
	echo "jenkins              $jenkins"
fi

if [ "$cstor" = "" ]; then
	echo "cstor                Not Running"
else
	echo "cstor                $cstor"
fi
