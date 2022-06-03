exports.handler = async (event) => {
    let taxIds = {};
    let i = 0;
    
    await new Promise(resolve => setTimeout(resolve, 5000));

    event.Records.forEach(function(record) {
        let taxId = record.dynamodb.Keys.TaxId.S
        if (taxIds[taxId] !== undefined) {
            taxIds[taxId] += 1;
        } else {
            taxIds[taxId] = 1;
        }
        i++;
    });
    
    console.log('Total Records: %d', i);

    await new Promise(resolve => setTimeout(resolve, 5000));

    Object.keys(taxIds).forEach(function (key) {
        console.log('TaxId %s: %d', key, taxIds[key])
     });

    let responseMessage = 'Hello, World!';

    return {
        statusCode: 202,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: responseMessage
        })
    }
}