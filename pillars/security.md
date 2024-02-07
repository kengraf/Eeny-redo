# Two suggestions to support Security pillar
# in Eeny-meeny-miny-moe app
1) Strong Identity foundation
2) Protect data (transit and at rest)
        
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
