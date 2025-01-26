# Report_inactive_external_users
This folder contains a Bicep template & deployment script for following resources:
1. Logic app to get a report of inactive external users
2. Logic app to delete inactive external users
3. User Managed identity
4. Teams API connector

## Requirements
Ensure you have the following prerequisites:
1. Azure subscription
2. Resource Group
    - Must have permission to deploy resources (e.g., Contributor role)
3. Azure CLI powershell module [https://learn.microsoft.com/en-us/cli/azure/install-azure-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
4. Microsoft Graph powershell module [https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
5. Ability to assign Microsoft Graph permissions to the managed identity (e.g., Application Administrator role)
6. Service account with licence to access teams
7. Teams team available for notifications

## Deployment

The deployment process involves the following manual steps:
1. Run the deployment script
2. Configure permissions for the managed identity
3. Authorize Microsoft Teams API Connection
4. Modify Microsoft Teams message target 
5. Modify LA-Entra-Delete-Inactive-Guests to actually be able to run and delete users

**Naming Scheme**  
You can choose from two naming conventions for the Logic App:
1. Without prefix: LA-Entra-Delete-Inactive-Guests
2. With prefix: EX-LA-Entra-Delete-Inactive-Guests

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
1. Go to the deployed Managed Identity in Azure
2. Copy the **Object (Principal) ID** value and assign it to the `$ObjectId` variable in the commands below.
3. Execute the following PowerShell commands:

The script below assigns the `Application.Read.All` permission to your managed identity.

```powershell
# Add the correct 'Object (principal) ID' for the Managed Identity
$ObjectId = "MIObjectID"

# Add the correct Graph scopes to grant (multiple scopes)
$graphScopes = @(
    "AuditLog.Read.All", 
    "User.ReadWrite.All"
)

# Connect to Microsoft Graph
Connect-MgGraph -Scope AppRoleAssignment.ReadWrite.All

# Get the Graph Service Principal
$graph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

# Loop through each scope and assign the role
foreach ($graphScope in $graphScopes) {
    # Find the corresponding AppRole for the current scope
    $graphAppRole = $graph.AppRoles | Where-Object { $_.Value -eq $graphScope }

    if ($graphAppRole) {
        # Prepare the AppRole Assignment
        $appRoleAssignment = @{
            "principalId" = $ObjectId
            "resourceId"  = $graph.Id
            "appRoleId"   = $graphAppRole.Id
        }

        # Assign the role
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ObjectId -BodyParameter $appRoleAssignment | Format-List
        Write-Host "Assigned $graphScope to Managed Identity $ObjectId"
    } else {
        Write-Warning "AppRole for scope '$graphScope' not found."
    }
}
```
And now you should have `AuditLog.Read.All` and `User.ReadWrite.All` permission assigned to your managed identity.

### Authorize connections

To authorize the required API connections, follow these steps:
1. Go to your resource group in Azure
2. Open the **O365 API Connection**
3. Click **Edit API Connection**
4. Click **Authorize** and sign in using the service account credentials

### Modifying Microsoft Teams action
1. Open your LA-Entra-Report-Inactive-Guests Logic App in Edit mode
2. Locate the action `Post message in a chat or channe` near the end of the workflow
3. Modify the following properties:
    - **Teams**: Select the appropriate team.
    - **Channel**: Choose the channel where the automation will post messages

### Activating LA-Entra-Delete-Inactive-Guests

The **LA-Entra-Delete-Inactive-Guests** Logic App is intentionally disabled in two different ways to prevent accidental deletions, ensuring that it only runs when you explicitly enable it.

> [!CAUTION]
This Logic App deletes the external users. As the time of writing deleted users are moved to Deleted Users and can be restored within 30 days. More information at [https://learn.microsoft.com/en-us/graph/api/user-delete?view=graph-rest-1.0&tabs=http](https://learn.microsoft.com/en-us/graph/api/user-delete?view=graph-rest-1.0&tabs=http)

#### Steps to activate:

1. **Enable the Logic App:**  
   - Navigate to the **LA-Entra-Delete-Inactive-Guests** Logic App in the Azure portal and enable it.  
   - You can find the "Enable" button in the top navigation bar.

2. **Remove the terminate action:**  
   - Edit the Logic App and remove the "Terminate" action to allow the workflow to proceed as intended.

#### Configuring the trigger:

Once the Logic App is enabled and updated, you can configure its trigger:

- To automate the execution, delete the existing trigger and replace it with a **Schedule** trigger.
- Alternatively, you can keep the HTTP request trigger and initiate the Logic App by making an HTTP request.  
  - For example, as a final step in the **LA-Entra-Report-Inactive-Guests** Logic App, you can add an HTTP GET request to invoke the **LA-Entra-Delete-Inactive-Guests** Logic App.

