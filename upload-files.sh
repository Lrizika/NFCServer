#!/bin/bash

if [[ $BASH_SOURCE = */* ]]; then
    cd -- "${BASH_SOURCE%/*}/"
fi

aws s3 --profile NFCFilesUploader sync ./files/ s3://nebulous-config-files
aws s3 --profile NFCFilesUploader sync ./files/887570/ s3://nebulous-map-mods

