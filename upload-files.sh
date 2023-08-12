#!/bin/bash

CONFIG_BUCKET="YOUR-CONFIG-BUCKET"
MODS_BUCKET="YOUR-MODS-BUCKET"

if [[ $BASH_SOURCE = */* ]]; then
    cd -- "${BASH_SOURCE%/*}/"
fi

aws s3 --profile NFCFilesUploader sync ./files/ s3://$CONFIG_BUCKET
aws s3 --profile NFCFilesUploader sync ./files/887570/ s3://$MODS_BUCKET

