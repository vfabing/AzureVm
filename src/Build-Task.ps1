param(
    [Int]$MajorVersionNumber = 0,
    [Int]$MinorVersionNumber = 0,
    [Int]$PatchVersionNumber = -2
)

function Get-CurrentBuildNumberFromTaskManifest
{
    param(
        [String]$TaskJsonFilePath = "azVmManagerTask/task.json"
    )

    # Get Task JSON File
    $TaskJson = Get-Content $TaskJsonFilePath | Out-String | ConvertFrom-Json

    # Convert Last Version Number to Integer
    $PatchVersionNumber = [convert]::ToInt32($TaskJson.version.Patch, 10);

    return $PatchVersionNumber;
}

function Update-VssExtensionManifest ([int]$MajorVersionNumber, [int]$MinorVersionNumber, [int]$PatchVersionNumber, [String]$VssExtensionFilePath = "vss-extension.json")
{
    # Get JSON File
    $VssExtensionManifest = Get-Content $VssExtensionFilePath | Out-String | ConvertFrom-Json

    # Save New Version Number to JSON
    $VssExtensionManifest.version = "$($MajorVersionNumber).$($MinorVersionNumber).$($PatchVersionNumber)";

    # Save JSON File
    $VssExtensionManifest | ConvertTo-Json -depth 100 | Set-Content $VssExtensionFilePath

    Write-Output "VssExtensionManifest updated"
}

function Update-TaskManifest ([int]$MajorVersionNumber, [int]$MinorVersionNumber, [int]$PatchVersionNumber, [String]$TaskJsonFilePath = "azVmManagerTask/task.json")
{
    # Get JSON File
    $TaskJson = Get-Content $TaskJsonFilePath | Out-String | ConvertFrom-Json

    # Save New Version Number to JSON
    $TaskJson.version.Major = $MajorVersionNumber
    $TaskJson.version.Minor = $MinorVersionNumber
    $TaskJson.version.Patch = $PatchVersionNumber;

    # Save JSON File
    $TaskJson | ConvertTo-Json -depth 100 | Set-Content $TaskJsonFilePath

    Write-Output "TaskJson updated"
}

function Update-PackageManifest ([int]$MajorVersionNumber, [int]$MinorVersionNumber, [int]$PatchVersionNumber, [String]$PackageManifestFilePath = "azVmManagerTask/package.json")
{
    # Get JSON File
    $PackageManifest = Get-Content $PackageManifestFilePath | Out-String | ConvertFrom-Json

    # Save New Version Number to JSON
    $PackageManifest.version = "$($MajorVersionNumber).$($MinorVersionNumber).$($PatchVersionNumber)";

    # Save JSON File
    $PackageManifest | ConvertTo-Json -depth 100 | Set-Content $PackageManifestFilePath

    Write-Output "PackageManifest updated"
}

if($PatchVersionNumber -eq -2){
    $PatchVersionNumber = Get-CurrentBuildNumberFromTaskManifest
}

Write-Output "Current Version Number $($MajorVersionNumber).$($MinorVersionNumber).$($PatchVersionNumber) updating to ==> $($MajorVersionNumber).$($MinorVersionNumber).$((++$PatchVersionNumber))"

Update-VssExtensionManifest -MajorVersionNumber $MajorVersionNumber -MinorVersionNumber $MinorVersionNumber -PatchVersionNumber $PatchVersionNumber

Update-TaskManifest -MajorVersionNumber $MajorVersionNumber -MinorVersionNumber $MinorVersionNumber -PatchVersionNumber $PatchVersionNumber

Update-PackageManifest -MajorVersionNumber $MajorVersionNumber -MinorVersionNumber $MinorVersionNumber -PatchVersionNumber $PatchVersionNumber

tfx extension create --manifest-globs vss-extension.json