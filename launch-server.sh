#!/bin/bash

if [[ $BASH_SOURCE = */* ]]; then
    cd -- "${BASH_SOURCE%/*}/"
fi

echo "Uploading files"
./upload-files.sh

echo "Launching instance"
aws ec2 run-instances --profile NFCServerLauncher --region us-west-2 --user-data file://./NFCServer-userdata.sh --cli-input-json file://./run-instances_template.json

