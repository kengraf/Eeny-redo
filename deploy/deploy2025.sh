#!/bin/bash

STACK=Eeny2025
S3BUCKET=eeny5-2025
REGION=us-west-2

if aws s3api head-bucket --bucket "$S3BUCKET" --region ${REGION} 2>/dev/null; then
  echo "Bucket '$S3BUCKET' exists."
else
  echo "Creating bucket '$S3BUCKET'."
  aws s3api create-bucket --bucket ${S3BUCKET} --region ${REGION}
fi
    
echo "Load lambdas to S3 bucket..."
pushd lambda/fetch2025
zip fetch.zip -xi index.py
aws s3 cp fetch2025.zip s3://${S3BUCKET}
popd

echo "Creating stack..."
# upload cf stack
STACK_ID=`aws cloudformation deploy --stack-name ${STACK} \
  --template-body file://cfStack2025.json --capabilities CAPABILITY_NAMED_IAM \
  --tags Key=DeployName,Value=${STACK} \
  --region ${REGION} --query "StackId" --output text`

aws cloudformation list-exports --query "Exports[?Name=='EENY2025_URL'].Value" --output text
