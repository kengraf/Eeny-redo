const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    let body;
    let statusCode = 200;
    const headers = {
        "Content-Type": "application/json"
    };
    
    console.log('Received SNS event:', JSON.stringify(event, null, 2));
    
    // Define parameters for DynamoDB operation
    const params = {
        TableName: 'eeny-redo',
        Item: { name: "Game Over" }
    };

    try {
        // Put item in DynamoDB table
        await dynamo.put(params).promise();

        return {
            statusCode: 200,
            body: JSON.stringify('Record added successfully')
        };
  } catch (err) {
    statusCode = 400;
    body = "Lambda error: " + JSON.stringify(err.message);
  }
  return {
    statusCode,
    body,
  };
};
