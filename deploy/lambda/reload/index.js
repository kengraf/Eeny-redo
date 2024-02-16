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
        Item: { Name: "Add more friends" }
    };

    try {
        // Put item in DynamoDB table
        await dynamo.put(params).promise();

        console.log('Record added successfully');
        
    } catch (err) {
        console.log('Lambda error: ' + JSON.stringify(err.message));
    }
};
