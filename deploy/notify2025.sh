aws sns create-topic --name AWSHealthNotifications
aws sns subscribe --topic-arn arn:aws:sns:us-east-2:123456789012:AWSHealthNotifications \
  --protocol email --notification-endpoint your-email@example.com

aws sns set-topic-attributes --topic-arn arn:aws:sns:us-east-2:123456789012:AWSHealthNotifications \
  --attribute-name Policy \
  --attribute-value '{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "health.amazonaws.com"
              },
              "Action": "SNS:Publish",
              "Resource": "arn:aws:sns:us-east-2:123456789012:AWSHealthNotifications"
          }
      ]
  }'

aws events put-rule --name AWSHealthDynamoDBAlerts \
  --event-pattern '{
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"],
    "detail": {
      "service": ["DynamoDB"],
      "region": ["us-east-2"]
    }
  }' \
  --state ENABLED

aws events put-targets --rule AWSHealthDynamoDBAlerts \
  --targets '[
    {
      "Id": "1",
      "Arn": "arn:aws:sns:us-east-2:123456789012:AWSHealthNotifications"
    }
  ]'

aws sns publish --topic-arn arn:aws:sns:us-east-2:123456789012:AWSHealthNotifications \
  --message "Test AWS Health Alert for DynamoDB us-east-2"

