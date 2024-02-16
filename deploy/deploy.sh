#!/bin/bash

# All the variables we need are in parameters.json
STACK=`jq -r '.[] | select(.ParameterKey == "DeployName") | .ParameterValue' parameters.json`
S3BUCKET=`jq -r '.[] | select(.ParameterKey == "S3bucketName") | .ParameterValue' parameters.json`

echo "Load S3 bucket..."
aws s3api create-bucket --bucket  ${S3BUCKET} --region ${AWS_REGION} --create-bucket-configuration LocationConstraint=${AWS_REGION}
# upload lambda functions
cd lambda/fetch
zip fetch.zip -xi index.js
aws s3 cp fetch.zip s3://${S3BUCKET}/fetch.zip
cd ../..
cd lambda/reload
zip reload.zip -xi index.js
aws s3 cp reload.zip s3://${S3BUCKET}/reload.zip
cd ../..

echo "Creating stack..."
# upload cf stack
STACK_ID=`aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://cfStack.json --capabilities CAPABILITY_NAMED_IAM --parameters file://parameters.json --tags file://tags.json --query "StackId" --output text`

echo "Waiting on ${STACK_ID} create completion..."
aws cloudformation wait stack-create-complete --stack-name ${STACK_ID}
aws cloudformation describe-stacks --stack-name ${STACK_ID} --query "Stacks[0].StackName" --output text
