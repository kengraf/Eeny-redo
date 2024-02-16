# Two suggestions to support Cost pillar
1) Project costs for 1M daily user requests
2) Adjust deployment code
        
## Project costs for 1M daily user requests
Used AWS Pricw  Estimator for costs

### DynamoDB
1 GB x 0.25 USD = 0.25 USD (Data storage cost)  
DynamoDB data storage cost (monthly): 0.25 USD  

Number of writes: 750 million per month  1M users * 30 days * 25 names in list  
Pricing calculations  
1 KB average item size / 1 KB = 1.00 unrounded write request units needed per item  
750,000,000.00 total write request units x 0.00000125 USD = 937.50 USD write request cost  
Monthly write cost (monthly): 937.50 USD  

Number of reads: 750 million per month * 1000000 multiplier = 750000000 per month
Pricing calculations
1 KB average item size / 4 KB = 0.25 unrounded read request units needed per item
375,000,000.00 total read request units x 0.00000025 USD = 93.75 USD read request cost
Monthly read cost (monthly): 93.75 USD

Storage: 0.25 + Write: 937.50 + Read:: 93.75 = Total monthly: 1,031.50 USD

### Lambda
Amount of memory allocated: 512 MB x 0.0009765625 GB in a MB = 0.5 GB
Amount of ephemeral storage allocated: 512 MB x 0.0009765625 GB in a MB = 0.5 GB
750,000,000 requests x 80 ms x 0.001 ms to sec conversion factor = 60,000,000.00 total compute (seconds)
Lambda costs - With Free Tier (monthly): 643.13 USD  

### API Gateway
1 KB per request / 512 KB request increment = 0.001953125 request(s)  
RoundUp (0.001953125) = 1 billable request(s)  
750 requests per month x 1,000,000 unit multiplier x 1 billable request(s) = 750,000,000 total billable request(s)  
HTTP API request cost (monthly): 705.00 USD  

###  Total monthly estimated = $26,555.56
---
## Adjust deployment code
- **DynamoDb** Dropped provisioned I/O for PAY_PER_REQUEST
- **Lambda** Changed memory size from default 128Mb to 512Mb
- **API** Changed from apigateway to apigatewayv2
