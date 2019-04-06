import tl = require('azure-pipelines-task-lib/task');
import armCompute = require("azure-arm-rest/azure-arm-compute");
import { AzureRMEndpoint } from 'azure-arm-rest/azure-arm-endpoint';

async function run() {
    try {
        const inputString: string = tl.getInput('samplestring', true);
        if (inputString == 'bad') {
            tl.setResult(tl.TaskResult.Failed, 'Bad input was given');
            return;
        }
        console.log('Hello', inputString);

        var connectedService = tl.getInput("ConnectedServiceName", true);
        var subscriptionId = tl.getEndpointDataParameter(connectedService, "SubscriptionId", true);
        var azureEndpoint = await new AzureRMEndpoint(connectedService).getEndpoint();
        var credentials = azureEndpoint.applicationTokenCredentials;

        var resourceGroupName = tl.getInput("resourceGroupName", true);
            
    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

run();