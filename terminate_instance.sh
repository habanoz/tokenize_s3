#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: region argument is not set"
  exit 1
fi

echo "### Session will be terminated!"
echo "### Installing AWS Cli"
sudo snap install aws-cli --classic

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region "$1"