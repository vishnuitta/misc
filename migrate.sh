#!/bin/bash
#set -x
#jenkins=`kubectl describe nodes | grep ExternalIP | awk '{print $2}'`
#remote_server=`sshpass -ptest ssh root@$REMOTE_SERVER kubectl get svc -o wide | grep ctrl | awk '{print $3}'`
#local_server=`kubectl get svc | grep ctrl | awk '{print $4}'`

if [ "$1" = "austin" ]; then
  local_server=`echo $austin`
elif [ "$1" = "denmark" ]; then
  local_server=`echo $denmark`
elif [ "$1" = "awseast" ]; then
  local_server=`echo $awseast`
else
  echo "$1 is not available in database"
  exit
fi

if [ "$2" = "austin" ]; then
  remote_server=`echo $austin`
elif [ "$2" = "denmark" ]; then
  remote_server=`echo $denmark`
elif [ "$2" = "awseast" ]; then
  remote_server=`echo $awseast`
else
  echo "$2 is not available in database"
  exit
fi

if [ "$local_server" = "" ]; then
  echo "local_server is NOT set."
  exit
fi

if [ "$remote_server" = "" ]; then
  echo "remote_server is NOT set."
  exit
fi

echo -ne "Getting app details"\\r
echo -ne "                   "\\r
jenkins=`kubectl get pods | grep jenkins | awk '{print $1}'`

echo -ne "Syncing app data"\\r
if [ "$jenkins" = "" ]; then
        echo "jenkins app not running."
	exit
else
	kubectl exec -it $jenkins -- sync /bin/bash >> /tmp/file1 2>&1
fi

mayactl cstor snapshot  destroy --server $local_server:30051 --name snap1 --volume temp_0 --pool spool >> /tmp/file1 2>&1

echo -ne "                "\\r
echo -ne "Getting storage ready for migration"\\r
mayactl cstor snapshot  create --server $local_server:30051 --name snap1 --volume temp_0 --pool spool >> /tmp/file1 2>&1

if [ $? != 0 ]; then
	echo -ne "                                   "\\r
	echo "In the middle of something, Please try later"
	exit
fi

echo -ne "                                   "\\r
echo -ne "Hold on!! Migrating"\\r
mayactl cstor snapshot  send --server $local_server:30051 --name snap1 --volume temp_0 --pool spool --remotecstor $remote_server --remoteuser root --remotepass Dhakad6133 --remotevol temp_0 --remotepool spool >> /tmp/file1 2>&1


if [ $? != 0 ]; then
	echo -ne "                                   "\\r
	echo "Please check the reachability of destination, Is the destination prepared to receive"
	exit
fi

sleep 5

echo -ne "                   "\\r
echo -ne "Launching app on migrated cluster"\\r
mayactl cstor volume reload --server $remote_server:30051 >> /tmp/file1 2>&1


if [ $? != 0 ]; then
	echo -ne "                                   "\\r
	echo "Oops!! The Destination suddenly became unavailable"
	exit
fi

echo -ne "                                 "\\r
echo -ne "Stopping app on local cluster"\\r
kubectl delete -f jenkins.yml >> /tmp/file1 2>&1

echo -ne "                             "\\r
echo "CMotion successful."

echo "Jenkins is now available at: http://$2.mayacloud.io:30080/"

#remotejenkins=`sshpass -ptest ssh root@$AWS_SERVER /home/ubuntu/demo3/getjenkins.sh`
#echo $remotejenkins
