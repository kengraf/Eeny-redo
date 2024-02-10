#!/bin/bash

# Create role for Lambda function
aws iam create-role --role-name Eeny-redo-lambda \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --assume-role-policy-document file://lambda-role.json \
    --output text
  
# Attach policy for DynamoDB access to role
aws iam put-role-policy --role-name Eeny-redo-lambda \
    --policy-name Eeny-redo-lambda --output text  \
    --policy-document file://lambda-policy.json  

aws dynamodb create-table \
    --table-name Eeny-redo \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --billing-mode PAY_PER_REQUEST  --output text  
      

ARN=`aws iam list-roles --output text \
    --query "Roles[?RoleName=='Eeny-redo-lambda'].Arn" `  

# Create Lambda
zip function.zip -xi index.js
aws lambda create-function --function-name Eeny-redo \
    --tags Key="Owner",Value="Eeny-redo" \
    --runtime nodejs16.x --role $ARN \
    --zip-file fileb://function.zip --memory-size 512 \
    --handler index.handler --output text   

# Give any API Gateway permission to invoke the Lambda
aws lambda add-permission \
    --function-name Eeny-redo --output text  \
    --action lambda:InvokeFunction \
    --statement-id AllowGateway \
    --principal apigateway.amazonaws.com  

# Create the Gateway
ARN=`aws lambda get-function --function-name Eeny-redo \
    --query Configuration.FunctionArn --output text`
aws apigatewayv2 create-api --name 'Eeny-redo' --protocol-type=HTTP \
    --tags Key="Owner",Value="Eeny-redo" \
    --target $ARN --output text  

# Create a GET method for a Lambda-proxy integration
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='Eeny-redo'].ApiId" `
    
aws apigatewayv2 create-integration --api-id $APIID \
    --integration-type AWS_PROXY --output text  \
    --integration-uri arn:aws:lambda:us-east-2:788715698479:function:Eeny-redo \
    --payload-format-version 1.0

# Create custom domain
ARN=`aws acm list-certificates --output text \
    --query "CertificateSummaryList[?DomainName=='*.cyber-unh.org'].CertificateArn" `
aws apigatewayv2 create-domain-name --domain-name eeny.cyber-unh.org \
    --domain-name-configurations CertificateArn=$ARN,EndpointType=REGIONAL
aws apigatewayv2 create-api-mapping --api-id $APIID \
    --domain-name eeny.cyber-unh.org --stage "\$default"

# Need to fix the Route53 record in the UI, CLI access is not available.

friends=("Alice" "Bob" "Charlie")
for i in "${friends[@]}"
do
   : 
  aws dynamodb put-item --table-name Eeny-redo --item \
    '{ "Name": {"S": "'$i'"} }' 
done
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='Eeny-redo'].ApiId" `
curl -v https://$APIID.execute-api.us-east-2.amazonaws.com/

