# Two suggestions to support Performance pillar in Eeny-meeny-miny-moe app
1) Measure overall efficiency
2) Optimize serverless deployment
        
## Measure overall efficiency
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
        let res = http.get('https://eeny.cyber-unh.org');
        check(res, { 'status was 200': r => r.status == 200 });
        sleep(1);
}
```

Run the test
```
k6 test.js
```
### Adding a batch of records to the database when needed

```
#!/bin/bash

# Specify the file name
file="fake-name-batch.json"

# Clear the file if it exists
> "$file"

# Define the number of strings to generate
num_strings=10

# Loop to generate and write numbered strings to the file
for ((i=1; i<=$num_strings; i++)); do
    echo "String $i" >> "$file"
done

echo "Numbered strings have been written to '$file'."
```
FYI: DynamoDB limits adds to 25 records in a sinlge batch

# The contents of add10.json
```
{
  "Eeny-redo": [
      { "PutRequest": { "Item": { "Name": { "S": "alice00" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice01" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice02" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice03" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice04" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice05" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice06" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice07" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice08" }}}},
      { "PutRequest": { "Item": { "Name": { "S": "alice09" }}}}
  ]
}

```
Add one batch of 10
```
aws dynamodb batch-write-item --request-items file://add10.json  
```


## Optimize serverless deployment
Using the load load testing to generate data on various lambda sizes.
Evaluation was done by via the Lambda console monitoring tools.
| Lambda size (Mb)  | Runtime (MSec)  | GbSeconds used |
| :---: | :---: | :---: |
|  128    |   506    |   0.0625  |
|  512    |    92    |  **_0.0460_**  |
|  1024   |    70    |   0.0700  |

---
Switch the gateway to apigatewayv2
This is preferred over the original use apigateway due to lower costs,
significant preformance improvements, and simpler CLI commands.
Additionally, v2 default deployments will handle lambda integrations,
stages, auto deployments, and custom domain names.  

