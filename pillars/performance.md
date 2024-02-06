# Two suggestions to support Performance pllar in Eeny-meeny-miny-moe app
1) Measure overall efficiency
2) Optimize serverless deployment
        
### Measure overall efficiency
Add a load generation process to eval response times.  
Good stress testing recomendations [here](https://www.inmotionhosting.com/support/server/server-usage/how-to-stress-test-your-website/).  
The example uses K6.
 
K6 install on AWS linux
```
sudo dnf install https://dl.k6.io/rpm/repo.rpm
sudo dnf install k6
```

Sample test.js running one stage with 100 requests.
```
import http from 'k6/http';
import { check, sleep } from 'k6';
export let options = {
        stages: [
                { duration: '20s', target: 100 },
        ],
};
export default function() {
        let res = http.get('https://example.com');
        check(res, { 'status was 200': r => r.status == 200 });
        sleep(1);
}
```

Run the test
```
k6 test.js
```
### Optimize serverless deployment
use load testing to generate data on various lambda sizes
128Mb average was 506 mSec yielding 0.0625 GbSeconds per request.  
512Mb average was 102 mSec yielding *0.051* GbSeconds per request.  
1024Mb average was 70 mSec yielding 0.07 GbSeconds per request.  

Optimize the apigatewayv2 is preferred over apigateway because of lower cost and significant preformance improvements.  

aws apigatewayv2 create-api --name 'EenyMeenyMinyMoe2' --protocol-type=HTTP \
    --tags Key=Owner,Value=Eeny \
    --target arn:aws:lambda:us-east-2:788715698479:function:EenyMeenyMinyMoe
aws apigatewayv2  create-domain-name --domain-name "eeny.cyber-unh.org" --domain-name-configurations CertificateArn=arn:aws:acm:us-east-2:788715698479:certificate/88eebf2a-230d-4a6d-a542-df76904bb108

# Create a GET method for a Lambda-proxy integration
```
APIID=`aws apigatewayv2 get-apis --output text \
    --query "Items[?Name=='EenyMeenyMinyMoe2'].ApiId" `
    
aws apigatewayv2 create-integration --api-id $APIID \
    --integration-type AWS_PROXY \
    --integration-uri arn:aws:lambda:us-east-2:788715698479:function:EenyMeenyMinyMoe \
    --payload-format-version 1.0

aws apigatewayv2 create-route \
  --api-id $APIID --route-key 'GET /test' \
  --target integrations/6txtqgu
  
-------------------------
PARENTID=`aws apigatewayv2 get-resources --api-id $APIID \
    --query 'items[0].id' --output text`
aws apigatewayv2 put-method --rest-api-id $APIID \
    --resource-id $PARENTID --http-method GET \
    --authorization-type "NONE"
```            
# Create integration with Lambda
```
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
```
# Push out deployment
aws apigatewayv2 create-stage --api-id $APIID --stage-name prod --auto-deploy
aws apigatewayv2 create-deployment --api-id $APIID --stage-name prod
