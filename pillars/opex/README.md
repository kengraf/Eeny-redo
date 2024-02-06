# Two suggestions to support Operational Excellence pillar in Eeny-meeny-miny-moe app
1) Perform operations as code
2) Anticipate failures 
        
### Perform operations as code
Set the APIgateway's URL: https://ewb9yq1n8e.execute-api.us-east-2.amazonaws.com/prod/
to something more friendly: https://eeny.cyber-unh.org/prod/

Change batch in a file
```
{
    "Comment": "Updated from Gitbug code",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "eeny.cyber-unh.org",
                "Type": "A",
                "TTL": 60,
                "ResourceRecords": [
                    {
                        "Value": "ewb9yq1n8e.execute-api.us-east-2.amazonaws.com"
                    },
                ]
            }
        },
    ]
}
```
# Replace hte zone id with your value
aws route53 change-resource-record-sets --hosted-zone-id ZRWFREAU725TM \
--change-batch file:/
 
### Anticipate failures 
(dependancies: missing, multiple, incomplete)

