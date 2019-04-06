import tl = require("vsts-task-lib/task");
import armCompute = require("azure-arm-rest/azure-arm-compute");
import { AzureRMEndpoint } from 'azure-arm-rest/azure-arm-endpoint';
import path = require("path");

async function run() {
    try {
        var vmName: string = tl.getInput('vmName', true);
        var resourceGroupName = tl.getInput("resourceGroupName", true);

        console.log(`vmName=${vmName}`);
        console.log(`resourceGroupName=${resourceGroupName}`);

        var connectedService = tl.getInput("ConnectedServiceName", true);
        var subscriptionId = tl.getEndpointDataParameter(connectedService, "SubscriptionId", true);
        var azureEndpoint = await new AzureRMEndpoint(connectedService).getEndpoint();
        var credentials = azureEndpoint.applicationTokenCredentials;

        var computeClient = new armCompute.ComputeManagementClient(credentials, subscriptionId);

        console.log(`Starting ${vmName}`);
        computeClient.virtualMachines.start(resourceGroupName, vmName, (error) => 
        {
            if(error) {
                tl.setResult(tl.TaskResult.Failed, `Could not start ${vmName}`);
            } else {
                console.log(`Started ${vmName}`)
            }
        });
    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

var taskManifestPath = path.join(__dirname, "task.json");
tl.debug("Setting resource path to " + taskManifestPath);
tl.setResourcePath(taskManifestPath);

run();