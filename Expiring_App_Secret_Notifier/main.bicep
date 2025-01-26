metadata name = 'Expiring App Secret Notifier'
metadata description = 'This bicep deploys Logic app automation for expiring app secret notifications by teams and email'
metadata author = 'Anssi Päivinen'
metadata Created = '25.01.2025'
metadata Modified = '25.01.2025'
metadata ChangeReason = 'Initial development'


targetScope = 'resourceGroup'

@description('Define a prefix to be attached to every service name')
param servicePrefix string

@description('Specifies who created the resource. This is used in Tags')
param createdBy string

@description('Define a name for resource group. By default uses the current resource group name')
param resourceGroup string = az.resourceGroup().name

@description('Specifies the location for resources. by default uses the current resource group location')
param location string = az.resourceGroup().location

@description('The deployment timestamp')
param deploymentTimestamp string = utcNow() // Example: 20241123T210053Z

var LogicAppname = empty(servicePrefix) ? 'LA-Entra-Expiring-App-Secret-Checker' : '${servicePrefix}-LA-Entra-Expiring-App-Secret-Checker'
var teamsConnectorName = '${LogicAppname}-teams'
var o365ConnectorName = '${LogicAppname}-o365'
var year = substring(deploymentTimestamp, 0, 4)          // Extracts '2024'
var month = substring(deploymentTimestamp, 4, 2)         // Extracts '11'
var day = substring(deploymentTimestamp, 6, 2)           // Extracts '23'
var formattedDate = '${day}.${month}.${year}'            // '23.11.2024'


resource teamsConnector 'Microsoft.Web/connections@2016-06-01' = {
  name: teamsConnectorName
  location: location
  tags: {
    Playbook: LogicAppname
    createdBy: createdBy
    createdOn: formattedDate
  }
  properties: {
    displayName: teamsConnectorName
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/teams'
    }
  }
}



resource o365Connector 'Microsoft.Web/connections@2016-06-01' = {
  name: o365ConnectorName
  location: location
  tags: {
    Playbook: LogicAppname
    createdBy: createdBy
    createdOn: formattedDate
  }
  properties: {
    displayName: o365ConnectorName
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
    }
  }
}

resource LogicApp 'Microsoft.Logic/workflows@2017-07-01' = {
  name: LogicAppname
  dependsOn:[
    teamsConnector
    o365Connector
  ]
  location: location
  tags: {
    Playbook: LogicAppname
    createdBy: createdBy
    createdOn: formattedDate
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            interval: 1
            frequency: 'Week'
          }
          evaluatedRecurrence: {
            interval: 1
            frequency: 'Week'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Get_future_time: {
          runAfter: {}
          type: 'Expression'
          kind: 'GetFutureTime'
          inputs: {
            interval: 1
            timeUnit: 'Month'
          }
        }
        'Initialize_variable_-_AppList-HTML': {
          runAfter: {
            Get_future_time: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'AppList-HTML'
                type: 'string'
              }
            ]
          }
        }
        'Initialize_variable_-_Counter': {
          runAfter: {
            'Initialize_variable_-_AppList-HTML': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Counter'
                type: 'integer'
                value: 0
              }
            ]
          }
        }
        'HTTP_-_Get_apps': {
          runAfter: {
            'Initialize_variable_-_Counter': [
              'Succeeded'
            ]
          }
          type: 'Http'
          inputs: {
            uri: 'https://graph.microsoft.com/v1.0/applications'
            method: 'GET'
            queries: {
              '$select': 'id,appId,DisplayName,passwordCredentials'
            }
            authentication: {
              type: 'ManagedServiceIdentity'
              audience: 'https://graph.microsoft.com'
            }
          }
          runtimeConfiguration: {
            contentTransfer: {
              transferMode: 'Chunked'
            }
          }
        }
        'Parse_JSON_-_HTTP_-_Get_apps': {
          runAfter: {
            'HTTP_-_Get_apps': [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'HTTP_-_Get_apps\')'
            schema: {
              properties: {
                '@@odata.context': {}
                value: {
                  items: {
                    properties: {
                      appId: {}
                      displayName: {}
                      id: {}
                      passwordCredentials: {
                        items: {
                          properties: {
                            customKeyIdentifier: {}
                            displayName: {}
                            endDateTime: {}
                            hint: {}
                            keyId: {}
                            secretText: {}
                            startDateTime: {}
                          }
                          type: 'object'
                        }
                        type: 'array'
                      }
                    }
                    type: 'object'
                  }
                  type: 'array'
                }
              }
              type: 'object'
            }
          }
        }
        'For_each_-_Apps': {
          foreach: '@outputs(\'Parse_JSON_-_HTTP_-_Get_apps\')?[\'body\']?[\'value\']'
          actions: {
            'For_each_-_Secrets': {
              foreach: '@items(\'For_each_-_Apps\')?[\'passwordCredentials\']'
              actions: {
                Condition: {
                  actions: {
                    Increment_variable: {
                      type: 'IncrementVariable'
                      inputs: {
                        name: 'Counter'
                        value: 1
                      }
                    }
                    Convert_time_zone: {
                      runAfter: {
                        Increment_variable: [
                          'Succeeded'
                        ]
                      }
                      type: 'Expression'
                      kind: 'ConvertTimeZone'
                      inputs: {
                        baseTime: '@items(\'For_each_-_Secrets\')?[\'endDateTime\']\r\n'
                        sourceTimeZone: 'UTC'
                        destinationTimeZone: 'FLE Standard Time'
                        formatString: 'dd.MM.yyyy klo HH:mm'
                      }
                    }
                    'Append_to_string_variable_-_AppList': {
                      runAfter: {
                        Convert_time_zone: [
                          'Succeeded'
                        ]
                      }
                      type: 'AppendToStringVariable'
                      inputs: {
                        name: 'AppList-HTML'
                        value: '<tr>\n\t<td>@{items(\'For_each_-_Apps\')?[\'displayName\']}</td>\n\t<td>@{items(\'For_each_-_Apps\')?[\'appId\']}</td>\n\t<td>@{items(\'For_each_-_Secrets\')?[\'displayName\']}</td>\n\t<td>@{body(\'Convert_time_zone\')}</td>\n</tr>'
                      }
                    }
                  }
                  else: {
                    actions: {}
                  }
                  expression: {
                    and: [
                      {
                        less: [
                          '@item()?[\'endDateTime\']'
                          '@body(\'Get_future_time\')'
                        ]
                      }
                    ]
                  }
                  type: 'If'
                }
              }
              type: 'Foreach'
            }
          }
          runAfter: {
            'Parse_JSON_-_HTTP_-_Get_apps': [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        'Condition_-_Check_if_AppList_contains_data': {
          actions: {
            'Compose_-_Message': {
              type: 'Compose'
              inputs: '<style>table, th, td {border: 1px solid;}table{width: 100%;border-collapse: collapse; }</style>\n<table>\n        <thead>\n            <tr>\n                <th>App Display Name</th>\n                <th>App ID</th>\n                <th>Secret Display Name</th>\n                <th>Secret Expiry Date</th>\n            </tr>\n        </thead>\n        <tbody>\n            @{variables(\'AppList-HTML\')}\n        </tbody>\n</table>'
            }
            Post_message_in_a_chat_or_channel: {
              runAfter: {
                'Compose_-_Message': [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'teams\'][\'connectionId\']'
                  }
                }
                method: 'post'
                body: {
                  recipient: {
                    groupId: 'SELECT-YOUR-TEAM-ID-HERE'
                    channelId: 'SELECT-YOUR-CHANNEL-ID-HERE'
                  }
                  messageBody: '<p class="editor-paragraph">@{outputs(\'Compose_-_Message\')}</p>'
                  subject: '@{variables(\'Counter\')} expiring app secrets found!'
                }
                path: '/beta/teams/conversation/message/poster/@{encodeURIComponent(\'User\')}/location/@{encodeURIComponent(\'Channel\')}'
              }
            }
            'Send_an_email_(V2)': {
              runAfter: {
                Post_message_in_a_chat_or_channel: [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
                  }
                }
                method: 'post'
                body: {
                  To: 'INSERT-EMAILS-HERE'
                  Subject: 'App secret expiry notification'
                  Body: '<h1 class="editor-heading-h1">There are @{variables(\'Counter\')} expiring app secrets!<br><br>@{outputs(\'Compose_-_Message\')}</h1>'
                  Importance: 'Normal'
                }
                path: '/v2/Mail'
              }
            }
          }
          runAfter: {
            'For_each_-_Apps': [
              'Succeeded'
            ]
          }
          else: {
            actions: {}
          }
          expression: {
            and: [
              {
                greater: [
                  '@variables(\'Counter\')'
                  0
                ]
              }
            ]
          }
          type: 'If'
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          teams: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/teams'
            connectionId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Web/connections/${teamsConnectorName}'
            connectionName: 'teams'
          }
          office365: {
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/office365'
            connectionId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup}/providers/Microsoft.Web/connections/${o365ConnectorName}'
            connectionName: 'office365'
          }
        }
      }
    }
  }
}
