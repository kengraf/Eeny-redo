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

## Create a Cloud Landing Zone (IAM, Database, and testing)

### IAM create roles and policies
AWS CLI requires files for packages, roles, and policies.  The example here assumes you have cloned this Github repo and are in the proper working directory

```
# Create role for Lambda function
aws iam create-role --role-name Eeny-redo-lambda \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --assume-role-policy-document file://lambda-role.json  

# Attach policy for DynamoDB access to role
aws iam put-role-policy --role-name Eeny-redo-lambda \
    --policy-name Eeny-redo-lambda \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --policy-document file://lambda-policy.json  
  
```

### DynamoDB: used to store your friend\'s names for the game 
Create a new table named *Eeny-redo*
```
aws dynamodb create-table \
    --table-name Eeny-redo \
    --tags "Key"="Owner","Value"="Eeny-redo" \
    --attribute-definitions AttributeName=Name,AttributeType=S  \
    --key-schema AttributeName=Name,KeyType=HASH  \
    --billing-mode PAY_PER_REQUEST  
      
```
   
```
# Add friend records for testing.  
friends=("Alice" "Bob" "Charlie")
for i in "${friends[@]}"
do
   : 
  aws dynamodb put-item --table-name Eeny-redo --item \
    '{ "Name": {"S": "'$i'"} }' 
done

```


## Create the app
Lambda and API gateway

## Run the app

## Clean Up by removing all the resources created
```
# Delete API Gateway
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='Eeny-redo'].ApiId" `
aws apigatewayv2 delete-api --api-id $APIID

# Delete Lambda function
aws lambda delete-function --function-name Eeny-redo

# Delete DynamoDB table
aws dynamodb delete-table --table-name Eeny-redo

# Delete Role and Policy
aws iam delete-role-policy --role-name Eeny-redo-lambda \
    --policy-name Eeny-redo-lambda
aws iam delete-role --role-name Eeny-redo-lambda
  
```

## Summary
There are still many unimplemented suggestions from the original repo.  This effort is to help the learning process, so maybe some day.


============================= snip =======================================
General game process
1) Drop a set of "friend's names" into DynamoDB
2) Invoke a lambda to pick a friend
3) Repeat until you run out of friends


### Lambda: used to select a friend
```
ARN=`aws iam list-roles --output text \
    --query "Roles[?RoleName=='Eeny-redo-lambda'].Arn" `

# Create Lambda
zip function.zip -xi index.js
aws lambda create-function --function-name EenyMeenyMinyMoe \
    --runtime nodejs14.x --role $ARN \
    --zip-file fileb://function.zip \
    --runtime nodejs14.x --handler index.handler
```
```
# Give the API Gateway permission to invoke the Lambda
aws lambda add-permission \
    --function-name EenyMeenyMinyMoe \
    --action lambda:InvokeFunction \
    --statement-id AllowGateway \
    --principal apigateway*.amazonaws.com
```

### API Gateway
```
# Create the Gateway
aws apigateway create-rest-api --name 'EenyMeenyMinyMoe' \
    --endpoint-configuration types=REGIONAL
```

```
# Create a GET method for a Lambda-proxy integration
APIID=`aws apigateway get-rest-apis --output text \
    --query "items[?name=='EenyMeenyMinyMoe'].id" `
PARENTID=`aws apigateway get-resources --rest-api-id $APIID \
    --query 'items[0].id' --output text`
aws apigateway put-method --rest-api-id $APIID \
    --resource-id $PARENTID --http-method GET \
    --authorization-type "NONE"
            
# Create integration with Lambda
ARN=`aws lambda get-function --function-name EenyMeenyMinyMoe \
    --query Configuration.FunctionArn --output text`
REGION=`aws ec2 describe-availability-zones --output text \
    --query 'AvailabilityZones[0].[RegionName]'`
URI='arn:aws:apigateway:'$REGION':lambda:path/2015-03-31/functions/'$ARN'/invocations'
aws apigateway put-integration --rest-api-id $APIID \
   --resource-id $PARENTID --http-method GET --type AWS_PROXY \
   --integration-http-method POST --uri $URI
aws apigateway put-integration-response --rest-api-id $APIID \
    --resource-id $PARENTID --http-method GET \
    --status-code 200 --selection-pattern "" 

# Push out deployment
aws apigateway create-deployment --rest-api-id $APIID --stage-name prod
```

### Run the game.  Each refresh will return a different name.
```
curl -v https://$APIID.execute-api.us-east-2.amazonaws.com/prod/
```

