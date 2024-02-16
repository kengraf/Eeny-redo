# Two suggestions to support Operational Excellence pillar
1) Perform operations as code
2) Anticipate failures 
        
## Perform operations as code
No real progress to full IaC without implementing an orchestration solution.

*Initial Phase*
The define code snippets in the repo's README.md based on AWS CLI.
- Cloud Landing Zone (IAM, Database, testing)
- App deployment (Lambda, API Gateway)
- Resource recovery

The number of snippets was reduced while increasing functionality.  However
the code remains fragile with redundant hard coded names, regions, and execution
order dependencies are still present.  

*Move to CloudFormation*
As an experiment, all the code snippets were combined in one script
file and then dumped in ChatGPT for translation to a CloudFormation JSON template. 

While the bulk of the translation was effective: parameterization, references,
and CLI assumed/default properties needed to be fixed.  Additionally ChatGPT
made a handful of schema errors, mostly due to ApiGateway vs ApiGatewayV2 differences.

*TBD*
Monitoring and performance tuning are still done by hand via the console UI.  

*Set a consistent ApiGateway URL to facilitate testing when deployment change*
The default creation gives us something like: 
https://<YOUR API ID>.execute-api.<REGION>.amazonaws.com/
The move apigatewayv2 allows for custom domains like:
https://eeny.cyber-unh.org/ which is independent of deployment generated ids.
See caveat note in README.md for CloudFormation limitations.
 
## Anticipate failures 
The original snippets had order dependencies caused by missing, multiple, incomplete,
and pending snippet execution.

- The order has improved, and the number of snippets reduced.  
- A single build is now available, so redundant builds in other regions can now be 
completed in less than one minute.
- A lambda function is now monitoring DynamoDB events to determine if recovery
steps are required.

