import tl = require("azure-pipelines-task-lib/task");
import armCompute = require("azure-arm-rest-v2/azure-arm-compute");
import { AzureRMEndpoint } from 'azure-arm-rest-v2/azure-arm-endpoint';
import path = require("path");

async function run() {
    try {
        var vmName: string = tl.getInput('vmName', true);
        var resourceGroupName = tl.getInput("resourceGroupName", true);
        var action = tl.getInput("Action", true);

        console.log(`vmName=${vmName}`);
        console.log(`resourceGroupName=${resourceGroupName}`);

        var connectedService = tl.getInput("ConnectedServiceName", true);
        var subscriptionId = tl.getEndpointDataParameter(connectedService, "SubscriptionId", true);
        var azureEndpoint = await new AzureRMEndpoint(connectedService).getEndpoint();
        var credentials = azureEndpoint.applicationTokenCredentials;

        var computeClient = new armCompute.ComputeManagementClient(credentials, subscriptionId);

        switch (action) {
            case "Start VM":
                console.log(`Starting ${vmName}`);
                computeClient.virtualMachines.start(resourceGroupName, vmName, (error: any, result?: any, request?: any, response?: any): void => {
                    if (error) {
                        tl.setResult(tl.TaskResult.Failed, `Could not start ${vmName}`);
                        tl.debug(`error: ${error}`);
                    } else {
                        console.log(`Started ${vmName}`);
                        tl.setResult(tl.TaskResult.Succeeded, "");
                    }
                    if(result) tl.debug(`result: ${result}`);
                    if(request) tl.debug(`request: ${request}`);
                    if(response) tl.debug(`response: ${response}`);
                });
                break;
            case "Stop VM":
                console.log(`Stopping ${vmName}`);
                computeClient.virtualMachines.powerOff(resourceGroupName, vmName, (error: any, result?: any, request?: any, response?: any): void => {
                    if (error) {
                        tl.setResult(tl.TaskResult.Failed, `Could not stop ${vmName}`);
                        tl.debug(`Stopping-error: ${error}`);
                    } else {
                        console.log(`Stopped ${vmName}`);
                        console.log(`Deallocating ${vmName}`);
                        computeClient.virtualMachines.deallocate(resourceGroupName, vmName, (error: any, result?: any, request?: any, response?: any): void => {
                            if (error) {
                                tl.setResult(tl.TaskResult.Failed, `Could not deallocate ${vmName}`);
                                tl.debug(`Deallocating-error: ${error}`);
                            } else {
                                console.log(`Deallocated ${vmName}`);
                                tl.setResult(tl.TaskResult.Succeeded, "");
                            }
                            if(result) tl.debug(`Deallocating-result: ${result}`);
                            if(request) tl.debug(`Deallocating-request: ${request}`);
                            if(response) tl.debug(`Deallocating-response: ${response}`);
                        });
                    }
                    if(result) tl.debug(`Stopping-result: ${result}`);
                    if(request) tl.debug(`Stopping-request: ${request}`);
                    if(response) tl.debug(`Stopping-response: ${response}`);
                });
                break;
            default:
                throw "InvalidAction";
        }

    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

var taskManifestPath = path.join(__dirname, "task.json");
tl.debug("Setting resource path to " + taskManifestPath);
tl.setResourcePath(taskManifestPath);

run();