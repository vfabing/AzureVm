param(
    [Int]$MajorVersionNumber = -2,
    [Int]$MinorVersionNumber = -2,
    [Int]$PatchVersionNumber = -2,
    [bool]$IsPublic = $false
)

function Get-CurrentMajorNumberFromTaskManifest {
    param(
        [String]$TaskJsonFilePath = "azVmManagerTask/task.json"
    )

    # Get Task JSON File
    $TaskJson = Get-Content $TaskJsonFilePath | Out-String | ConvertFrom-Json

    # Convert Last Version Number to Integer
    $MajorVersionNumber = [convert]::ToInt32($TaskJson.version.Major, 10);

    return $MajorVersionNumber;
}

function Get-CurrentMinorNumberFromTaskManifest {
    param(
        [String]$TaskJsonFilePath = "azVmManagerTask/task.json"
    )

    # Get Task JSON File
    $TaskJson = Get-Content $TaskJsonFilePath | Out-String | ConvertFrom-Json

    # Convert Last Version Number to Integer
    $MinorVersionNumber = [convert]::ToInt32($TaskJson.version.Minor, 10);

    return $MinorVersionNumber;
}

function Get-CurrentPatchNumberFromTaskManifest {
    param(
        [String]$TaskJsonFilePath = "azVmManagerTask/task.json"
    )

    # Get Task JSON File
    $TaskJson = Get-Content $TaskJsonFilePath | Out-String | ConvertFrom-Json

    # Convert Last Version Number to Integer
    $PatchVersionNumber = [convert]::ToInt32($TaskJson.version.Patch, 10);

    return $PatchVersionNumber;
}

function Update-VssExtensionManifest ([int]$MajorVersionNumber, [int]$MinorVersionNumber, [int]$PatchVersionNumber, [String]$VssExtensionFilePath = "vss-extension.json", [bool]$IsPublic) {
    # Get JSON File
    $VssExtensionManifest = Get-Content $VssExtensionFilePath | Out-String | ConvertFrom-Json

    # Save New Version Number to JSON
    $VssExtensionManifest.version = "$($MajorVersionNumber).$($MinorVersionNumber).$($PatchVersionNumber)";

    if (-Not ($IsPublic)) {
        Write-Output "Update-VssExtensionManifest IsPublic = false";
        if (-Not ($VssExtensionManifest.id.Contains("-private"))) {
            $VssExtensionManifest.id = "$($VssExtensionManifest.id)-private";
            $VssExtensionManifest.public = $false;
        }
    }
    else {
        Write-Output "Update-VssExtensionManifest IsPublic = true";
        if ($VssExtensionManifest.id.Contains("-private")) {
            $VssExtensionManifest.id = $VssExtensionManifest.id -replace "-private";
            $VssExtensionManifest.public = $true;
        }
    }


    # Save JSON File
    $VssExtensionManifest | ConvertTo-Json -depth 100 | Set-Content $VssExtensionFilePath

    Write-Output "VssExtensionManifest updated"
}

function Update-TaskManifest ([int]$MajorVersionNumber, [int]$MinorVersionNumber, [int]$PatchVersionNumber, [String]$TaskJsonFilePath = "azVmManagerTask/task.json", [bool]$IsPublic) {
    # Get JSON File
    $TaskJson = Get-Content $TaskJsonFilePath | Out-String | ConvertFrom-Json

    # Save New Version Number to JSON
    $TaskJson.version.Major = $MajorVersionNumber
    $TaskJson.version.Minor = $MinorVersionNumber
    $TaskJson.version.Patch = $PatchVersionNumber;

    if (-Not ($IsPublic)) {
        Write-Output "Update-TaskManifest IsPublic = false";
        $TaskJson.id = "895e12ba-6cdf-45be-99ff-c5699db169b8";
        if (-Not ($TaskJson.friendlyName.Contains("-private"))) {
            $TaskJson.friendlyName = "$($TaskJson.friendlyName)-private";
            $TaskJson.description = "$($TaskJson.description)-private";
        }
    }
    else {
        Write-Output "Update-TaskManifest IsPublic = true";
        $TaskJson.id = "d8a5bb69-bcfa-43eb-943d-692e191805fd";
        if ($TaskJson.friendlyName.Contains("-private")) {
            $TaskJson.friendlyName = $TaskJson.friendlyName -replace "-private";
            $TaskJson.description = $TaskJson.description -replace "-private";
        }
    }

    # Save JSON File
    $TaskJson | ConvertTo-Json -depth 100 | Set-Content $TaskJsonFilePath

    Write-Output "TaskJson updated"
}

function Update-PackageManifest ([int]$MajorVersionNumber, [int]$MinorVersionNumber, [int]$PatchVersionNumber, [String]$PackageManifestFilePath = "azVmManagerTask/package.json") {
    # Get JSON File
    $PackageManifest = Get-Content $PackageManifestFilePath | Out-String | ConvertFrom-Json

    # Save New Version Number to JSON
    $PackageManifest.version = "$($MajorVersionNumber).$($MinorVersionNumber).$($PatchVersionNumber)";

    # Save JSON File
    $PackageManifest | ConvertTo-Json -depth 100 | Set-Content $PackageManifestFilePath

    Write-Output "PackageManifest updated"
}

if ($MajorVersionNumber -lt -1) {
    $MajorVersionNumber = Get-CurrentMajorNumberFromTaskManifest
}

if ($MinorVersionNumber -lt -1) {
    $MinorVersionNumber = Get-CurrentMinorNumberFromTaskManifest
}

if ($PatchVersionNumber -lt -1) {
    $PatchVersionNumber = Get-CurrentPatchNumberFromTaskManifest
}

If (Test-Path -Path "azVmManagerTask/node_modules/azure-arm-rest/openssl/OpenSSL License.txt") { 
    Write-Output "Whitespace in filename found [[OpenSSL License.txt]]";
    Write-Output "Renaming to  [[OpenSSL_License.txt]]";
    Rename-Item -Path "azVmManagerTask/node_modules/azure-arm-rest/openssl/OpenSSL License.txt" -NewName "OpenSSL_License.txt"
}

Write-Output "Version Number $($MajorVersionNumber).$($MinorVersionNumber).$($PatchVersionNumber)"

Update-VssExtensionManifest -MajorVersionNumber $MajorVersionNumber -MinorVersionNumber $MinorVersionNumber -PatchVersionNumber $PatchVersionNumber -IsPublic $IsPublic

Update-TaskManifest -MajorVersionNumber $MajorVersionNumber -MinorVersionNumber $MinorVersionNumber -PatchVersionNumber $PatchVersionNumber -IsPublic $IsPublic

Update-PackageManifest -MajorVersionNumber $MajorVersionNumber -MinorVersionNumber $MinorVersionNumber -PatchVersionNumber $PatchVersionNumber

tsc --build azVmManagerTask/tsconfig.json
tfx extension create --manifest-globs vss-extension.json