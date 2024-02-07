# Two suggestions to support Operational Excellence pillar
1) Perform operations as code
2) Anticipate failures 
        
## Perform operations as code
No real progress to full IaC without implymenting an orcastration solution.
A single shell command file (build-eeny-redo.sh) is now included.
The following have defined code snippets based on AWS CLI.
- Cloud Landing Zone (IAM, Database, testing)
- App deployment (Lambda, API Gateway)
- Resource recovery

The number of snippets was reduced while increasing functionality.  However
the code remains fragile with redundant hard coded names, regions, and execution
order dependencies still present.  

Monitoring and performance tuning are still done by hand via the console UI.  

*Set a consistent ApiGateway URL to facilitate testing when deployment change*
The default creation gives us something like: 
https://<YOUR API ID>.execute-api.<REGION>.amazonaws.com/
The move apigatewayv2 allows for custom domains like:
https://eeny.cyber-unh.org/ which is independent of deployment generated ids.

 
## Anticipate failures 
The original snippets had order dependencies caused by missing, multiple, incomplete,
and pending snippet execution.

- The order has improved, and the number of snippets reduced.  
- A single build is now available, so redundant builds in other regions can now be 
completed in less than one minute.
- A lambda function is now monitoring DynamoDB events to determine if recovery
steps are required.

