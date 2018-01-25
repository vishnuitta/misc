#!/bin/bash
#x=`curl 35.189.77.40:30050` 2>&1 
#echo $x
echo $0
echo $1
if [ "$1" = "test_env" ]; then
  var1=`echo $TEST_ENV`
fi
echo $var1
echo $$1

