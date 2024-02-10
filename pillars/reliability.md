# Two suggestions to support Reliability pillar in Eeny-meeny-miny-moe app
1) Test recovery procedures
2) Automatically recover from failure
        
### Test recovery procedures
mini-ChaosMonkey  

###  Automatically recover from failure
event on delete of db, rebuild.
Use X-ray to monitor events
Step 1: Enable tracing the lambda function
```
aws lambda update-function-configuration  \
        --function-name Eeny-redo --output text \
        --tracing-config Mode=Active
```
Step 2: Add trace information for request to dynamoDB
```
const AWS = require('aws-sdk');
const AWSXRay = require('aws-xray-sdk');
AWSXRay.captureAWS(AWS);
const dynamodb = new AWS.DynamoDB();
```
