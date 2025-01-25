# LogicApp-Expiring-App-Secret-Notifier
This repository contains bicep template for expiring entra id app secret notify automation

## Requirements
You need to have following:
1. Azure subscription
2. Resource Group
    - With permmission level to deploy resources (for example Contributor)
3. Azure CLI powershell module [https://learn.microsoft.com/en-us/cli/azure/install-azure-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
    - Bicep CLI (should be already installed if you have Azure CLI module)
4. Microsoft Graph powershell module [https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
5. Permissions to assign Microsoft Graph permissions to managed identity (for example Application Administrator role)
6. Service account with licence to access teams & outlook
7. Teams team available


## Deployment

Deployment requires few manual steps:
1. run deployment script
2. Configure permissions to managed identity
3. Authorize teams & email connectors
4. Modify teams & email message recipients


There are two possibilities for naming scheme for the logic app. For example:
1. Name without prefix = LA-Entra-Expiring-Secret-Checker
2. Name with prefix = EX-LA-Entra-Expiring-Secret-Checker

Modify the script parameters to match your environment
- myResourceGroup = the resource group where azure resources are deployed
- createdBy = The one who deploys the resources, used for tags
- servicePrefix = optional prefix, for example abreviation of a company

Deploy without prefix run following command in powershell:

```powershell
.\deploy.ps1 -ResourceGroupName "myResourceGroup" -createdBy "John Doe"

```
Deploy with prefix run following command in powershell:

```powershell
.\deploy.ps1 -ResourceGroupName "myResourceGroup" -createdBy "John Doe" -servicePrefix "EX"

```

## Post-Deployment

### Permissions to Managed identity

1. Go to your logic app in Azure
2. Open Idenitity from left navigation (Under Settings category) 
3. Copy **Object (principal) ID** value to `$ObjectID` variables value bellow a
4. Copy & paste commands bellow to powershell window (Run the commands)

And now you should have `Application.Read.All` permission assigned to your managed identity.


```powershell
# Add the correct 'Object (principal) ID' for the Managed Identity
$ObjectId = "MIObjectID"

# Add the correct Graph scope to grant
$graphScope = "Application.Read.All"

Connect-MgGraph -Scope AppRoleAssignment.ReadWrite.All
$graph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

$graphAppRole = $graph.AppRoles | ? Value -eq $graphScope

$appRoleAssignment = @{
    "principalId" = $ObjectId
    "resourceId"  = $graph.Id
    "appRoleId"   = $graphAppRole.Id
}

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ObjectID -BodyParameter $appRoleAssignment | Format-List
```

### Authorize connections
1. Go to your resource group in Azure.
2. Open o365 API connection
3. Go to Edit API connection
4. Press authorize and login with your service account
5. Repeat steps to teams API connection

### Modify teams and outlook actions
1. Open your logic app in edit mode
2. Find `Post message in a chat or channe` action at the end of the logic app
3. Modify at least following properties:
    - Teams (Select your desired team)
    - Channel (Select your channel where the automation will post a message)
4. Find `Send an email (V2)` action bellow teams message and modify at least To-field with your email recipients