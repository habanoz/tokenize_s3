#!/bin/bash
echo "### Starting initialization..."
AWS_REGION="{{AWS_REGION}}"
BUCKET="{{BUCKET}}"
echo "### AWS region $AWS_REGION"
echo "### Bucket $BUCKET"
git clone https://github.com/habanoz/tokenize_s3.git
cd tokenize_s3
chmod +x run.sh
./run.sh "$BUCKET"
chmod +x terminate_instance.sh
./terminate_instance.sh "$AWS_REGION"
