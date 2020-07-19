# AzureVm

[Azure Virtual Machine Manager Task](https://marketplace.visualstudio.com/items?itemName=vfabing.AzureVirtualMachineManagerTask)

## Prerequisites
- Install [NodeJS](https://nodejs.org/en/download/)

```powershell
npm install -g typescript
npm install mocha --save-dev -g
npm install -g tfx-cli
```

## Restore files
At the `azVmManagerTask` folder level
```powershell
npm i
```

## Run tests
At the `src` folder level
```powershell
.\Run-Tests.ps1
```

## Build extension
At the `src` folder level
```powershell
.\Build-Task.ps1
```
