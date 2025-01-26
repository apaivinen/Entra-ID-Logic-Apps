<# 
.SYNOPSIS
    Deploys the logic app to the specified resource group.

.DESCRIPTION
    This script deploys the logic app to the specified resource group.
    The script takes the following parameters:
    - ResourceGroupName: The name of the Resource group to deploy the logic app to.
    - createdBy: Name of the one who deploys the logic app.
    - servicePrefix: Prefix for the logic app name. OPTIONAL

    REQUIREMENTS
    - Azure CLI
    - Bicep CLI (should be already installed if you have up to date Azure CLI)

.PARAMETER ResourceGroupName
    The name of the Resource group to deploy the logic app to.

.PARAMETER createdBy
    Name of the one who deploys the logic app.

.PARAMETER servicePrefix
    Prefix for the logic app name. OPTIONAL

.EXAMPLE
    .\deploy.ps1 -ResourceGroupName "myResourceGroup" -createdBy "John Doe"
.EXAMPLE
    .\deploy.ps1 -ResourceGroupName "myResourceGroup" -createdBy "John Doe" -servicePrefix "myService"

.NOTES
    Version:            1.0
    Author:             Anssi Päivinen
    Created Date:       2025-01-26
    Modified Date:      2025-01-26
    Purpose/Change:     Initial script development

#>


[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, HelpMessage="The name of the Resource group to deploy the logic app to")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true,HelpMessage="Name of the one who deploys the logic app")]
    [string]$createdBy,

    [Parameter(Mandatory=$false,HelpMessage="Prefix for the logic app name. OPTIONAL")]
    [string]$servicePrefix
) 

$deploymentTime = Get-Date -Format "yyyyMMddHHmmss"


az deployment group create `
    --name "LogicAppDeployment-$deploymentTime" `
    --resource-group $ResourceGroupName `
    --template-file "main.bicep" `
    --parameters `
        createdBy=$createdBy `
        servicePrefix=$servicePrefix

Write-Host "Deployment completed." -ForegroundColor Yellow