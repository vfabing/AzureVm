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
                computeClient.virtualMachines.start(resourceGroupName, vmName, (error) => {
                    if (error) {
                        tl.setResult(tl.TaskResult.Failed, `Could not start ${vmName}`);
                    } else {
                        console.log(`Started ${vmName}`);
                    }
                });
                break;
            case "Stop VM":
                console.log(`Stopping ${vmName}`);
                computeClient.virtualMachines.powerOff(resourceGroupName, vmName, (error) => {
                    if (error) {
                        tl.setResult(tl.TaskResult.Failed, `Could not stop ${vmName}`);
                    } else {
                        console.log(`Stopped ${vmName}`);
                        console.log(`Deallocating ${vmName}`);
                        computeClient.virtualMachines.deallocate(resourceGroupName, vmName, (error) => {
                            if (error) {
                                tl.setResult(tl.TaskResult.Failed, `Could not deallocate ${vmName}`);
                            } else {
                                console.log(`Deallocated ${vmName}`)
                            }
                        });
                    }
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