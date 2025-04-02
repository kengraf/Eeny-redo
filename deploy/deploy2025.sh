#!/bin/bash

# All the variables we need are in parameters.json
STACK=Eeny2025
S3BUCKET=Eeny-redo

echo "Load lambdas to S3 bucket..."
cd lambda/fetch2025
zip fetch.zip -xi index.py
aws s3 cp fetch2025.zip s3://${S3BUCKET}/fetch.zip
cd ../..

echo "Creating stack..."
# upload cf stack
STACK_ID=`aws cloudformation deploy --stack-name ${STACK} \
  --template-body file://cfStack.json --capabilities CAPABILITY_NAMED_IAM \
  --parameters file://parameters.json --tags Key=DeployName,Value=${STACK} \
    --query "StackId" --output text`

aws cloudformation describe-stacks --stack-name ${STACK_ID} --query "Stacks[0].StackName" --output text
