#!/bin/bash

IS_GCLOUD_INSTALLED=$(which gcloud>> /dev/null 2>&1; echo $?)
if [ $IS_GCLOUD_INSTALLED -eq 0 ]; then
     echo "gcloud sdk is installed; Skipping"
     sleep 2
else

     echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
     sudo apt-get update && sudo apt-get install -y google-cloud-sdk kubectl
     gcloud auth activate-service-account --key-file=$KEY_FILE
fi
