# Eeny-redo

This is a fork of kengraf/eeny-meeny-miny-moe.  
This repo demonstrates of the simple things that can be implemented to to improve the overall architecture of the original repo.
The improvements are motivated by AWS's Well-Architected service.  Details of each improvement are the pillars folder.

CloudFormation, or alternative, would certainly makes sense is this was for production.  For now we still using the CLI.

Clone this repo and use the Cloud shell to issue the commands.
```
git clone https://github.com/kengraf/Eeny-redo.git
cd Eeny-redo
```
### Single build (all snippets)
./build-eeny-redo.sh

## Create a Cloud Landing Zone (IAM, Database, and testing)

### IAM create roles and policies
AWS CLI requires files for packages, roles, and policies.  The example here assumes you have cloned this Github repo and are in the proper working directory

```
# Create role for Lambda function
aws iam create-role --role-name Eeny-redo-lambda \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --assume-role-policy-document file://lambda-role.json \
    --output text
  
# Attach policy for DynamoDB access to role
aws iam put-role-policy --role-name Eeny-redo-lambda \
    --policy-name Eeny-redo-lambda --output text \
    --policy-document file://lambda-policy.json  

```

### DynamoDB: used to store your friend\'s names for the game 
Create a new table named *Eeny-redo*
```
aws dynamodb create-table \
    --table-name Eeny-redo --output text \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --billing-mode PAY_PER_REQUEST  
      
```

### Testing
Refer to pillars/performance.md

## Create the app (Lambda and API gateway)
### Lambda: used to select a friend
```
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
    --function-name Eeny-redo --output text \
    --action lambda:InvokeFunction \
    --statement-id AllowGateway \
    --principal apigateway.amazonaws.com  

```
### API Gateway V2
```
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
    --integration-type AWS_PROXY --output text \
    --integration-uri arn:aws:lambda:us-east-2:788715698479:function:Eeny-redo \
    --payload-format-version 1.0

# Create custom domain
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
            "Name": "eeny2.cyber-unh.org.", "Type": "A",
            "AliasTarget": { "HostedZoneId": "'$HOSTZONE'",
                "DNSName": "'$DNSNAME'" } } } ] }'

```
## Run the game
### Load some friends
```
friends=("Alice" "Bob" "Charlie")
for i in "${friends[@]}"
do
   : 
  aws dynamodb put-item --table-name Eeny-redo --item \
    '{ "Name": {"S": "'$i'"} }' 
done
```
Each refresh will return a different name.
```
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='Eeny-redo'].ApiId" `
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
    --query "Items[?Name=='Eeny-redo'].ApiId" `
aws apigatewayv2 delete-api --api-id $APIID

# Delete Lambda function
aws lambda delete-function --function-name Eeny-redo --output text

# Delete DynamoDB table
aws dynamodb delete-table --table-name Eeny-redo --output text

# Delete Role and Policy
aws iam delete-role-policy --role-name Eeny-redo-lambda \
    --policy-name Eeny-redo-lambda --output text
aws iam delete-role --role-name Eeny-redo-lambda --output text
  
```

## Summary
There are still many unimplemented suggestions from the original repo.  This effort is to help the learning process, so maybe some day.  Review the content in the pillars folder to see what was done in this fork.
