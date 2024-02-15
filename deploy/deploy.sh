#!/bin/bash

STACK_NAME=$1

if [ -z "$1" ]
  then
    echo "No STACK_NAME argument supplied"
    exit 1
fi

sed -ri "s/undefined-deploy/${STACK_NAME}/" parameters.json

S3BUCKET=$STACK_NAME-$(tr -dc a-f0-9 </dev/urandom | head -c 10)
sed -ri "s/undefined-bucket/${S3BUCKET}/" parameters.json
sed -ri "s/${STACK_NAME}-[0-9a-f]*/${S3BUCKET}/" parameters.json

echo "Create S3 bucket..."
REGION=`aws configure get region`
aws s3api create-bucket --bucket  ${STACK_NAME} --region ${REGION}

echo "Creating stack..."

# upload lambda functions
cd lambda/fetch
zip fetch.zip -xi index.js
aws s3 cp fetch.zip s3://${S3BUCKET}/deploy/lambda/fetch.zip
cd ../..
cd lambda/reload
zip reload.zip -xi index.js
aws s3 cp reload.zip s3://${S3BUCKET}/deploy/lambda/reload.zip
cd ../..

# upload cf stack
aws cloudformation create-stack --stack-name ${STACK_NAME} --template-body file://cfStack.json --capabilities CAPABILITY_NAMED_IAM --parameters file://parameters.json --tags file://tags.json --output text
STACK_ID=`aws cloudformation describe-stacks --stack-name ${STACK_NAME} --query "Stacks[0].StackId" --output text`

echo "Waiting on ${STACK_ID} create completion..."
aws cloudformation wait stack-create-complete --stack-name ${STACK_ID}
aws cloudformation describe-stacks --stack-name ${STACK_ID} jq .Stacks[0].Outputs
