# Suggestions to support Security pillar

1) Strong Identity foundation
2) Protect data (transit and at rest)
3) Implement multi-layered API security
        
## Strong Identity foundation
A small set of roles and policies are required for app components to communicate.
Those IAM components have been separated and are now defined as part of the organization\'s Cloud Landing Zone.  
    
## Protect data (transit and at rest)
No keys are managed externally to AWS.
The app code is for demonstration purposes only, is public, and not considered sensitive.
The only sensitive app data is a list of friends.

**At rest:** Previously the data existed as a string in a script managed on Github and
in the DynamoDB database.  DynamoDB is encrypted by default.  In the Github script (demo.sh)
the array of names was removed.  Names are now provided only at script runtime.

**In transit:** Remote access to the API Gateway is only available using TLS.  Realtime
access to the components in this app are available to properly authorized users via the console
and CLI, introspection of transactions is possible for those users.

---
## Implement multi-layered API security
[AWS Well-Architected Security Workshop](https://catalog.workshops.aws/well-architected-security/en-US/4-infrastructure-protection/multilayered-api-security-with-cognito-and-waf)
### Notes: 
Step 1: Create the API
- The first Cloudformation yaml needs to be modified.  The current RDS version doesn't support instance type db.t2.micro it needs to be changed to db.m6gd.large.
- Validating with cloud9 the front works unprotected is a nice confirmation.
- Copy the APIgateway URL from stack outputs.
Step 2: Ket rotation
- Skipped, a nice lesson but the later steps automate key rotation.
Step 3: Create security stack
In cloud9
```
cd walab-scripts/
chmod +x install_package.sh 
./install_package.sh 
python sendRequest.py https://vs75alwh36.execute-api.us-east-1.amazonaws.com/Dev/?id=1
python sendRequest.py https://d1cy5ijtcvw16s.cloudfront.net/?id=1
```
Step 4: WAF setup
```
# Show SQLi
python sendRequest.py 'https://d1cy5ijtcvw16s.cloudfront.net/?id=1 oe 1=1'
```
Add WAF SQLi rule.  These are base on ModSecurity rules.  Replay of the above attack will now fail.
Step 5: Cognito
```
python getIDtoken.py <username> <user_password> <user_pool_id> <app_client_id> <app_client_secret>
python sendRequest.py https://d1cy5ijtcvw16s.cloudfront.net <ID_Token>
```
