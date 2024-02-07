# Two suggestions to support Operational Excellence pillar in Eeny-meeny-miny-moe app
1) Perform operations as code
2) Anticipate failures 
        
## Perform operations as code
No real progress to full IaC without implymenting an orcastration solution.  
The following have defined code snippets based on AWS CLI.
- Cloud Landing Zone (IAM, Database, testing)
- App deployment (Lambda, API Gateway)
- Resource recovery

The number of snippents was reduced while increasing functionality.  However
the code remains fragile with redundent hard coded names, regions, and execution
order dependencies still present.  

Monitoring and performance tuning are still done by hand via the console UI.  

*Set a consistent APIgateway URL to facilitate testing when deployment change*
The defualt creation gives us something like: 
https://<YOUR API ID>.execute-api.<REGION>.amazonaws.com/
The move apigatewayv2 allows for custom domains like:
https://eeny.cyber-unh.org/ which is independant of deployment generated ids.

 
## Anticipate failures 
(dependancies: missing, multiple, incomplete)

