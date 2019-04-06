import ma = require('vsts-task-lib/mock-answer');
import tmrm = require('vsts-task-lib/mock-run');
import path = require('path');

let taskPath = path.join(__dirname, '..', 'azurevmmanager.js');
let tmr: tmrm.TaskMockRunner = new tmrm.TaskMockRunner(taskPath);


tmr.setInput("ConnectedServiceName", "AzureRM");
tmr.setInput("resourceGroupName", "myVm-rg");
tmr.setInput('vmName', 'myVm');

process.env["AGENT_TEMPDIRECTORY"] = path.join(__dirname, '..');
process.env["ENDPOINT_AUTH_AzureRM"] = "{\"parameters\":{\"serviceprincipalid\":\"id\",\"serviceprincipalkey\":\"key\",\"tenantid\":\"tenant\"},\"scheme\":\"ServicePrincipal\"}";
process.env["ENDPOINT_AUTH_PARAMETER_AzureRM_SERVICEPRINCIPALID"] = "id";
process.env["ENDPOINT_AUTH_PARAMETER_AzureRM_SERVICEPRINCIPALKEY"] = "key";
process.env["ENDPOINT_AUTH_PARAMETER_AzureRM_TENANTID"] = "tenant";
process.env["ENDPOINT_DATA_AzureRM_SUBSCRIPTIONID"] = "sId";
process.env["ENDPOINT_DATA_AzureRM_SUBSCRIPTIONNAME"] = "sName";
process.env["ENDPOINT_URL_AzureRM"] = "https://management.azure.com/";
process.env["ENDPOINT_DATA_AzureRM_ENVIRONMENTAUTHORITYURL"] = "https://login.windows.net/";
process.env["ENDPOINT_DATA_AzureRM_ACTIVEDIRECTORYSERVICEENDPOINTRESOURCEID"] = "https://management.azure.com";

tmr.registerMock('vsts-task-lib/toolrunner', require('vsts-task-lib/mock-toolrunner'));
tmr.registerMock('azure-arm-rest/azure-arm-compute', require('./mock_node_modules/azure-arm-compute'));

tmr.run();
