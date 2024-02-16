# Eeny-redo

This is a fork of kengraf/eeny-meeny-miny-moe.  
This repo demonstrates some of the simple things that can be implemented to improve the overall architecture of the original repo.
The improvements are motivated by AWS's Well-Architected service.  Details of each improvement are in the pillars folder.

An example CloudFormation template and deploy script are provided, or you use the aws cli command listed below.

Clone this repo.  All commands assume you are using the AWS Cloud shell.
```
git clone https://github.com/kengraf/Eeny-redo.git
cd Eeny-redo
```
---

## CloudFormation approach
```
cd deploy
# Change 'eeny-redo' to your app name
find . -type f  -exec sed -i 's/eeny-redo/<YOUR-APP-NAME/g' {} \;
```

In parameters.json change
- The S3 bucket entry to the bucket you want to hold the lambda zip files.
- The domain name to your domain.

Package up the lambdas and deploy the CloudFormation template.
```
chmod +x deploy.sh
./deploy.sh
```
### CloudFormation caveat
A bug/feature when attempting to defined a "AWS::ApiGatewayV2::DomainName" resource.

The DomainName property below is required but, all attempted values return a schema read only error.
AWS recommends creating a lambda based custom resource as a workaround.
Which is a lot of work just to have a friendly URL for a short-term project.  
If friendly URL is desired the CLI commands below can be used.
```
    "CustomDomain": {
      "Type": "AWS::ApiGatewayV2::DomainName",
      "Properties": {
        "DomainNameConfigurations": [
          {
            "CertificateArn": { "Ref": "CustomDomainCertificate" },
            "SecurityPolicy": "TLS_1_2",
            "EndpointType": "REGIONAL"
          }         
        ],
        "DomainName" : {"Fn::Sub" : "${CustomSubdomainName}"},
      }
    }
```
---
## Create eeny-redo app using AWS CLI
### IAM create roles and policies
AWS CLI requires files for packages, roles, and policies.  The example here assumes you have cloned this Github repo and are in the proper working directory.

```
# Create role for Lambda function
aws iam create-role --role-name eeny-redo-lambda \
    --tags "Key"="Owner","Value"="eeny-redo" \
    --assume-role-policy-document file://lambda-role.json \
    --output text
  
# Attach policy for DynamoDB access to role
aws iam put-role-policy --role-name eeny-redo-lambda \
    --policy-name eeny-redo-lambda --output text \
    --policy-document file://lambda-policy.json  

```

### DynamoDB: used to store your friend\'s names for the game 
Create a new table named *eeny-redo*
```
aws dynamodb create-table \
    --table-name eeny-redo --output text \
    --tags "Key"="Owner","Value"="eeny-redo" \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --billing-mode PAY_PER_REQUEST  
      
```
### Lambda: used to select a friend
```
ARN=`aws iam list-roles --output text \
    --query "Roles[?RoleName=='eeny-redo-lambda'].Arn" `  

# Creat lambda to re-fill database
cd lambda/reload
zip reload.zip -xi index.js
LAMBDA_ARN=`aws lambda create-function --function-name eeny-redo-reload \
    --tags Key="Owner",Value="eeny-redo" \
    --runtime nodejs16.x --role $ARN \
    --zip-file fileb://reload.zip \
    --handler index.handler --query FunctionArn --output text `   
cd ../..

# Create Lambda to receive requests
cd lambda/fetch
zip fetch.zip -xi index.js
aws lambda create-function --function-name eeny-redo-fetch \
    --tags Key="Owner",Value="eeny-redo" \
    --runtime nodejs16.x --role $ARN \
    --zip-file fileb://fetch.zip --memory-size 512 \
    --handler index.handler --output text   
cd ../..

# Create the SNS topic and tie endpoint to refill lambda
SNS_ARN=`aws sns create-topic --name eeny-redo-reload --output text --query 'TopicArn'`
aws sns subscribe \
    --topic-arn $SNS_ARN --protocol lambda \
    --notification-endpoint $LAMBDA_ARN

# Give Lambda permission to be invoked by SNS
aws lambda add-permission \
    --function-name eeny-redo-reload \
    --statement-id sns-invoke \
    --action "lambda:InvokeFunction" \
    --principal sns.amazonaws.com \
    --source-arn $SNS_ARN

# Give any API Gateway permission to invoke the Lambda
aws lambda add-permission \
    --function-name eeny-redo-fetch --output text \
    --action lambda:InvokeFunction \
    --statement-id AllowGateway \
    --principal apigateway.amazonaws.com  

```
### API Gateway V2
```
# Create the Gateway
ARN=`aws lambda get-function --function-name eeny-redo-fetch \
    --query Configuration.FunctionArn --output text`
aws apigatewayv2 create-api --name 'eeny-redo-Api' --protocol-type=HTTP \
    --tags Key="Owner",Value="eeny-redo" \
    --target $ARN --output text

# Create a GET method for a Lambda-proxy integration
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='eeny-redo-Api'].ApiId" `
    
aws apigatewayv2 create-integration --api-id $APIID \
    --integration-type AWS_PROXY --output text \
    --integration-uri arn:aws:lambda:us-east-2:788715698479:function:eeny-redo-fetch \
    --payload-format-version 1.0
```

### Optional: Create custom domain (AWS CloudFormation workaround)
```
ARN=`aws acm list-certificates --output text \
    --query "CertificateSummaryList[?DomainName=='*.cyber-unh.org'].CertificateArn" `
aws apigatewayv2 create-domain-name --output text \
    --domain-name eeny.cyber-unh.org \
    --domain-name-configurations CertificateArn=$ARN,EndpointType=REGIONAL
aws apigatewayv2 create-api-mapping --api-id $APIID --output text \
    --domain-name eeny.cyber-unh.org --stage "\$default"

# Need to fix the Route53 record.
Needed is the domain name of the mapping not the gateway\'s domain.
aws route53 list-resource-record-sets --hosted-zone-id ZRWFREAU725TM --query "ResourceRecordSets[?Name=='eeny.cyber-unh.org.']"

ZONEID=`aws route53 list-hosted-zones-by-name --dns-name cyber-unh.org --query "HostedZones[0].Id" --output text`
DNSNAME=`aws apigatewayv2 get-domain-names --output text --query \
    "Items[?DomainName=='eeny.cyber-unh.org'].DomainNameConfigurations[0].ApiGatewayDomainName"`'.'
HOSTZONE=`aws apigatewayv2 get-domain-names --output text --query \
    "Items[?DomainName=='eeny.cyber-unh.org'].DomainNameConfigurations[0].HostedZoneId"`
aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID --change-batch '{
      "Changes": [ { "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "eeny.cyber-unh.org.", "Type": "A",
            "AliasTarget": { "HostedZoneId": "'$HOSTZONE'",
                "DNSName": "'$DNSNAME'", "EvaluateTargetHealth": false } } } ] }'  

```
---
## Run the game
### Load some friends
```
friends=("Alice" "Bob" "Charlie")
for i in "${friends[@]}"
do
   : 
  aws dynamodb put-item --table-name eeny-redo --item \
    '{ "Name": {"S": "'$i'"} }' 
done

```
Each refresh will return a different name.
```
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='eeny-redo-Api'].ApiId" `
curl -v https://$APIID.execute-api.us-east-2.amazonaws.com/

```

## Clean Up by removing all the resources created
```
# Delete API Gateway
MAPID=`aws apigatewayv2 get-api-mappings \
    --domain-name eeny.cyber-unh.org  --output text \
    --query Items[0].ApiMappingId`
aws apigatewayv2 delete-api-mapping \
    --api-mapping-id $MAPID --domain-name eeny.cyber-unh.org

APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='eeny-redo-Api'].ApiId" `
aws apigatewayv2 delete-api --api-id $APIID

# Delete Lambda function
aws lambda delete-function --function-name eeny-redo-fetch --output text
aws lambda delete-function --function-name eeny-redo-reload --output text
TOPIC=`aws sns list-topics --output text --query \
    "Topics[?contains(TopicArn, 'eeny-redo-reload')].TopicArn" `
aws sns delete-topic --topic-arn $TOPIC

# Delete DynamoDB table
aws dynamodb delete-table --table-name eeny-redo --output text

# Delete Role and Policy
aws iam delete-role-policy --role-name eeny-redo-lambda \
    --policy-name eeny-redo-lambda --output text
aws iam delete-role --role-name eeny-redo-lambda --output text  
  
```
---
## Summary
There are still many unimplemented suggestions from the original repo.  This effort is to help the learning process, so maybe someday.  Review the content in the pillars folder to see what was done in this fork.
