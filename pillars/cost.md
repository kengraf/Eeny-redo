# Two suggestions to support Cost pillar in Eeny-meeny-miny-moe app
1) Project costs for 1M daily user requests
2) Adjust deployment code
        
## Project costs for 1M daily user requests

## Adjust deployment code
**DynamoDb** Dropped provisioned I/O for PAY_PER_REQUEST
**Lambda** Changed memory size from default 128Mb to 512Mb
**API** Changed from apigateway to apigatewayv2