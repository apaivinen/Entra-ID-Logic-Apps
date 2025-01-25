# LogicApp-Expiring-App-Secret-Notifier
This folder contains a Bicep template & deployment script for automation which notifies expiring Entra ID app secrets.

## Requirements
Ensure you have the following prerequisites:
1. Azure subscription
2. Resource Group
    - Must have permission to deploy resources (e.g., Contributor role)
3. Azure CLI powershell module [https://learn.microsoft.com/en-us/cli/azure/install-azure-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
4. Microsoft Graph powershell module [https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
5. Ability to assign Microsoft Graph permissions to the managed identity (e.g., Application Administrator role)
6. Service account with licence to access teams & outlook
7. Teams team available for notifications

## Deployment

The deployment process involves the following manual steps:
1. Run the deployment script
2. Configure permissions for the managed identity
3. Authorize Microsoft Teams & email connectors
4. Modify Microsoft Teams & email message recipients

**Naming Scheme**  
You can choose from two naming conventions for the Logic App:
1. Without prefix: LA-Entra-Expiring-Secret-Checker
2. With prefix: EX-LA-Entra-Expiring-Secret-Checker

**Deployment Parameters**
Modify the script parameters to match your environment
- myResourceGroup = the resource group where azure resources are deployed
- createdBy = The one who deploys the resources, used for tags
- servicePrefix = optional prefix, for example abreviation of a company

To deploy without a prefix, run the following command in PowerShell:

```powershell
.\deploy.ps1 -ResourceGroupName "myResourceGroup" -createdBy "John Doe"

```
To deploy with a prefix, run the following command in PowerShell:

```powershell
.\deploy.ps1 -ResourceGroupName "myResourceGroup" -createdBy "John Doe" -servicePrefix "EX"

```

## Post-Deployment

### Assigning Permissions to the Managed Identity

Follow these steps to assign permissions to the managed identity:  
1. Go to your Logic App in Azure
2. Navigate to **Identity** from the left navigation pane (under the **Settings** category).
3. Copy the **Object (Principal) ID** value and assign it to the `$ObjectId` variable in the commands below.
4. Execute the following PowerShell commands:

The script below assigns the `Application.Read.All` permission to your managed identity.

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
And now you should have `Application.Read.All` permission assigned to your managed identity.

### Authorize connections

To authorize the required API connections, follow these steps:
1. Go to your resource group in Azure
2. Open the **O365 API Connection**
3. Click **Edit API Connection**
4. Click **Authorize** and sign in using the service account credentials
5. Repeat the above steps for the Teams API Connection

### Modifying Microsoft Teams and Outlook Actions
1. Open your Logic App in Edit mode
2. Locate the action `Post message in a chat or channe` near the end of the workflow
3. Modify the following properties:
    - **Teams**: Select the appropriate team.
    - **Channel**: Choose the channel where the automation will post messages
4. Locate the action `Send an email (V2)` below the Teams message action and modify the To field to include the required email recipients