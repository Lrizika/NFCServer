# Table of Contents

- [Deploying a Nebulous: Fleet Command dedicated server to AWS](#deploying-a-nebulous--fleet-command-dedicated-server-to-aws)
  * [Prerequisites](#prerequisites)
  * [Summary of files and directories](#summary-of-files-and-directories)
  * [S3 buckets](#s3-buckets)
  * [IAM and permissions configuration](#iam-and-permissions-configuration)
    + [Users](#users)
    + [Roles](#roles)
    + [Key pair](#key-pair)
  * [Server configuration](#server-configuration)
  * [Deploying the server](#deploying-the-server)
  * [Detailed examination of `NFCServer-userdata.sh`](#detailed-examination-of--nfcserver-userdatash-)

# Deploying a Nebulous: Fleet Command dedicated server to AWS

This script automates the deployment of the N:FC dedicated server to an AWS EC2 instance (c7a.xlarge by default). Note that it does not configure any sort of automatic backups, restarts, or updates (I only run a server for several hours a week, and as such simply terminate the instance when I am done) - you may wish to look into Switchback's [N-FE-ASRU](https://github.com/switchback028/N-FE-ASRU/) utility if such are desired.

## Prerequisites

In order to run this script, you will need:
- Administrator access to AWS, in order to configure the appropriate roles and permissions
- The [AWS CLI](https://aws.amazon.com/cli/)

If you wish to run any mods on the server, you will also need to have a copy of them and your `appworkshop_887570.acf` file; more details on that later.

## Summary of files and directories

- `launch-server.sh` - The main script. Calls `upload-files.sh` then launches the EC2 instance.
- `upload-files.sh` - Helper script. Uploads mod and config files to S3.
- `NFCServer-userdata.sh` - Server setup script. We'll examine this later.
- `run-instances_template.json` - Configuration for the EC2 instance launched by `launch-server.sh`
- `files/cloudwatch-config.json` - Configuration for the Cloudwatch agent on the server.
- `files/nfc-server.service` - Unit configuration file for the systemctl NFC server service
- `files/config.xml` - A symlink to your customized NFC server config file
- `files/887570` - A symlink to your NFC mods directory (usually `steamapps/workshop/content/887570/`)
- `files/appworkshop_887570.acf` - A symlink to your NFC mods config file (usually `steamapps/workshop/appworkshop_887570.acf`)
- `policies/*` - IAM policies
- `example-config.xml` - The default NFC server example config

## S3 buckets

You will need two S3 buckets, one for mods and one for config files. You will need to update the `CONFIG_BUCKET` and `MODS_BUCKET` variables in `upload-files.sh` and `NFCServer-userdata.sh` to their appropriate names.

## IAM and permissions configuration

To deploy the server, you will need to create several IAM users and roles. The policies for these are in the /policies directory of this repository.

### Users

You will need two users to run the scripts. For each of these users, you will need to create them in IAM, create an access key, then configure a profile for them in the AWS CLI by running [`aws configure`](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html).
- `nebulous-files-upload`, which has the `nebulous-files-read-write` policy attached. `upload-files.sh` uses this user to upload config and mod files to our S3 buckets. The script expects the AWS CLI to have access to this user through the profile `NFCFilesUploader`.
- `nebulous-server-launcher`, with the `nebulous-instance-launchonly` policy. `launch-server.sh` uses this user to run the EC2 instance. The AWS CLI should have access through the profile `NFCServerLauncher`.

### Roles

You will need one role, called `nebulous-s3-and-cloudwatch`. This role should have the `nebulous-files-readonly` and `CloudWatchAgentServerPolicy` policies attached, and have [EC2 as a trusted entity](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html#roles-creatingrole-service-console).

### Key pair

If you want to be able to access the server over SSH, you'll need a [key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to attach to the instance. The default configuration uses a key pair named `NFCServer`.

## Server configuration

The server configuration file should be symlinked from `files/config.xml`. The EC2 instance launch options [can be configured in `run-instances_template.json`](https://awscli.amazonaws.com/v2/documentation/api/2.0.34/reference/ec2/run-instances.html). If you want to change the region, you'll also need to adjust the `--region` flag in `launch-server.sh`.

## Deploying the server

Once you have created the S3 buckets (and updated the relevant variables in the scripts), set up IAM, and customized your server configuration, it's time to deploy! Run `launch-server.sh` to deploy, then either SSH in or live tail the logs on Cloudwatch to ensure everything works properly.

## Detailed examination of `NFCServer-userdata.sh`

`NFCServer-userdata.sh` is where the server setup actually happens - let's take a look at what exactly it does:



