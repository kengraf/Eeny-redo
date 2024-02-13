# Two suggestions to support Reliability pillar in Eeny-meeny-miny-moe app
1) Test recovery procedures
2) Automatically recover from failure
        
### Test recovery procedures
mini-ChaosMonkey  
```
# Delete records to force an empty database
# Get all the records
aws dynamodb scan --table-name Eeny-redo --output text --query "Items[].Name.S" > items.txt
sed -i 's/\t/\n/g' items.txt

# Loop through the list, deleting everything
while read -r name; do
        echo $name
        aws dynamodb delete-item --table-name Eeny-redo \
                --key "{\"Name\":{\"S\":\"$name\"}}"
done < items.txt

```

###  Automatically recover from failure
The database needs to be refilled when empty
The recovery process is:
1) Eeny-redo-lambda invokes the SNS topic "Eeny-redo-reload" when zero records are returned
2) The SNS topic invokes the lambda function: "Eeny-redo-reload"
3) The lambda function refills the database.  The current lambda just adds a "Game Over" entry
