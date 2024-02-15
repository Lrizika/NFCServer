#!/bin/bash

CONFIG_BUCKET="nebulous-config-files"

if [[ $BASH_SOURCE = */* ]]; then
    cd -- "${BASH_SOURCE%/*}/"
fi

aws s3 --profile NFCFilesUploader sync ./files/ s3://$CONFIG_BUCKET

