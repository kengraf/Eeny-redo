import boto3
import json

def create_sns_topic(topic_name):
    sns = boto3.client("sns", region_name="us-east-2")
    response = sns.create_topic(Name=topic_name)
    return response["TopicArn"]

def subscribe_to_sns(topic_arn, email):
    sns = boto3.client("sns", region_name="us-east-2")
    sns.subscribe(TopicArn=topic_arn, Protocol="email", Endpoint=email)
    print(f"Subscription request sent to {email}. Please confirm via email.")

def set_sns_policy(topic_arn):
    sns = boto3.client("sns", region_name="us-east-2")
    policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {"Service": "health.amazonaws.com"},
                "Action": "SNS:Publish",
                "Resource": topic_arn
            }
        ]
    }
    sns.set_topic_attributes(
        TopicArn=topic_arn,
        AttributeName="Policy",
        AttributeValue=json.dumps(policy)
    )

def create_eventbridge_rule(rule_name, topic_arn):
    events = boto3.client("events", region_name="us-east-2")
    rule_response = events.put_rule(
        Name=rule_name,
        EventPattern=json.dumps({
            "source": ["aws.health"],
            "detail-type": ["AWS Health Event"],
            "detail": {
                "service": ["DynamoDB"],
                "region": ["us-east-2"]
            }
        }),
        State="ENABLED"
    )
    events.put_targets(
        Rule=rule_name,
        Targets=[{"Id": "1", "Arn": topic_arn}]
    )
    return rule_response

def main():
    topic_name = "AWSHealthNotifications"
    rule_name = "AWSHealthDynamoDBAlerts"
    email = "your-email@example.com"  # Change to your email
    
    print("Creating SNS topic...")
    topic_arn = create_sns_topic(topic_name)
    print(f"SNS Topic ARN: {topic_arn}")
    
    print("Subscribing email to SNS...")
    subscribe_to_sns(topic_arn, email)
    
    print("Setting SNS policy...")
    set_sns_policy(topic_arn)
    
    print("Creating EventBridge rule...")
    create_eventbridge_rule(rule_name, topic_arn)
    print("Setup complete. Please confirm SNS email subscription.")

if __name__ == "__main__":
    main()
