const AWS = require('aws-sdk');
const dynamodbClient = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event) => {
 
    AWS.config.update({
        region:  "us-east-1",
    });

    for (let i = 0; i < 400; i++) {
        var records = [];
        for (let j = 0; j < 25; j++) {
            const uuid = AWS.util.uuid.v4();
            let putRequest = [
                {
                    PutRequest: {
                        Item: {
                            "RequestId": { "S" : uuid },
                            "TaxId": { "S" : "00001" },
                            "InvoiceNumber": { "S" : "AWS-" + uuid }
                        }
                    }
                },
                {
                    
                    PutRequest: {
                        Item: {
                            "RequestId": { "S" : uuid },
                            "TaxId": { "S" : "00002" },
                            "InvoiceNumber": { "S" : "ADS-" + uuid }
                        }  
                    }
                },
                {
                    PutRequest: {
                        Item: {
                            "RequestId": { "S" : uuid },
                            "TaxId": { "S" : "00003" },
                            "InvoiceNumber": { "S" : "TFS-" + uuid }
                        }  
                    }
                }
            ];

            records.push(putRequest[j % 3]);
        }

        var params = {
            RequestItems: {
                'Request': records
            }
        };

        await dynamodbClient.batchWriteItem(params).promise()
        .then((data) => {
            console.info('successfully update to dynamodb', data)
        })
        .catch((err) => {
            console.info('failed adding data dynamodb', err)
        });
    }

}