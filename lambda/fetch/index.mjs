const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler =  async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json"
  };

  try {
    switch (event.rawPath) {
      case "/":
        var result = await dynamo.scan ({ TableName: 'Eeny-redo', }).promise();
        if (result.Count == 0) {
          // Publish message to the specified SNS topic
          const sns = new AWS.SNS();
          // Parameters for publishing a message to an SNS topic
          let data = await sns.listTopics().promise();
          let topic = data.Topics.find(t => t.TopicArn.includes("Eeny-redo-reload"));
 
          let params = {
            Message: 'Hello from Lambda!',
            TopicArn: topic.TopicArn
          };
          data = await sns.publish(params).promise();
          console.log("Message sent to SNS:", data.MessageId);
          body = "Game Over";
          break;
        }
        var picked = Math.floor(Math.random() * result.Count);
        body = result.Items[picked].Name;
        await dynamo.delete({
          TableName: "Eeny-redo",
          Key: { Name: body },
          ReturnValues: 'ALL_OLD',
         })
          .promise()
         .then(data => console.log(data.Attributes))
        .catch(console.error); 
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}" event: ` + JSON.stringify(event) );
    }
  } catch (err) {
    statusCode = 400;
    body = "Lambda error: " + JSON.stringify(err.message);
  }

  return {
    statusCode,
    body,
    headers
  };
};
