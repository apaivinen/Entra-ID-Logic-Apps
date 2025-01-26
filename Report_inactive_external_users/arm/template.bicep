param connections_LA_Entra_Inactive_Guests_teams_name string = 'LA-Entra-Inactive-Guests-teams'
param workflows_LA_Entra_Delete_Inactive_Guests_name string = 'LA-Entra-Delete-Inactive-Guests'
param workflows_LA_Entra_Report_Inactive_Guests_name string = 'LA-Entra-Report-Inactive-Guests'
param userAssignedIdentities_LA_Entra_Inactive_Guests_identity_name string = 'LA-Entra-Inactive-Guests-identity'

resource userAssignedIdentities_LA_Entra_Inactive_Guests_identity_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: userAssignedIdentities_LA_Entra_Inactive_Guests_identity_name
  location: 'westeurope'
  tags: {
    Playbook: 'LA-Entra-Inactive-Guests'
    createdBy: 'A'
    createdOn: '26.01.2025'
  }
}

resource connections_LA_Entra_Inactive_Guests_teams_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_LA_Entra_Inactive_Guests_teams_name
  location: 'westeurope'
  tags: {
    Playbook: 'LA-Entra-Inactive-Guests'
    createdBy: 'A'
    createdOn: '26.01.2025'
  }
  kind: 'V1'
  properties: {
    displayName: connections_LA_Entra_Inactive_Guests_teams_name
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    nonSecretParameterValues: {}
    createdTime: '2025-01-26T14:16:19.6502669Z'
    changedTime: '2025-01-26T14:38:42.3571414Z'
    api: {
      name: 'teams'
      displayName: 'Microsoft Teams'
      description: 'Microsoft Teams enables you to get all your content, tools and conversations in the Team workspace with Microsoft 365.'
      iconUri: 'https://conn-afd-prod-endpoint-bmc9bqahasf3grgk.b01.azurefd.net/releases/v1.0.1719/1.0.1719.3955/teams/icon.png'
      brandColor: '#4B53BC'
      id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/teams'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        requestUri: 'https://management.azure.com:443/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/DEV-Entra-Inactive-Users/providers/Microsoft.Web/connections/${connections_LA_Entra_Inactive_Guests_teams_name}/extensions/proxy/beta/me/teamwork?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}

resource workflows_LA_Entra_Delete_Inactive_Guests_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_LA_Entra_Delete_Inactive_Guests_name
  location: 'westeurope'
  tags: {
    Playbook: 'LA-Entra-Inactive-Guests'
    createdBy: 'A'
    createdOn: '26.01.2025'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/DEV-Entra-Inactive-Users/providers/Microsoft.ManagedIdentity/userAssignedIdentities/LA-Entra-Inactive-Guests-identity': {}
    }
  }
  properties: {
    state: 'Disabled'
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
        When_a_HTTP_request_is_received: {
          type: 'Request'
          kind: 'Http'
        }
      }
      actions: {
        Get_past_time: {
          runAfter: {
            'Terminate_-_REMOVE_THIS_IF_YOU_REALLY_WANT_TO_RUN_THIS_FLOW': [
              'Succeeded'
            ]
          }
          type: 'Expression'
          kind: 'GetPastTime'
          inputs: {
            interval: 12
            timeUnit: 'Month'
          }
        }
        'Initialize_variable_-_tableRows': {
          runAfter: {
            Get_past_time: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'tableRows'
                type: 'string'
                value: '@null'
              }
            ]
          }
        }
        Parse_JSON: {
          runAfter: {
            Until: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'HTTP_-_Get_Guest_users\')'
            schema: {
              type: 'object'
              properties: {
                statusCode: {
                  type: 'integer'
                }
                headers: {
                  type: 'object'
                  properties: {
                    'Cache-Control': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Transfer-Encoding': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    Vary: {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Strict-Transport-Security': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'request-id': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'client-request-id': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'x-ms-ags-diagnostic': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'x-ms-resource-unit': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'OData-Version': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    Date: {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Content-Type': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Content-Length': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                  }
                }
                body: {
                  type: 'object'
                  properties: {
                    '@@odata.context': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    value: {
                      type: 'array'
                      items: {
                        type: 'object'
                        properties: {
                          displayName: {
                            type: [
                              'string'
                              'null'
                            ]
                          }
                          userPrincipalName: {
                            type: [
                              'string'
                              'null'
                            ]
                          }
                          id: {
                            type: [
                              'string'
                              'null'
                            ]
                          }
                          signInActivity: {
                            type: 'object'
                            properties: {
                              lastSignInDateTime: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastSignInRequestId: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastNonInteractiveSignInDateTime: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastNonInteractiveSignInRequestId: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastSuccessfulSignInDateTime: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastSuccessfulSignInRequestId: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        For_each: {
          foreach: '@outputs(\'Parse_JSON\')?[\'body\']?[\'value\']'
          actions: {
            Condition: {
              actions: {
                Append_to_string_variable: {
                  type: 'AppendToStringVariable'
                  inputs: {
                    name: 'tableRows'
                    value: '<tr><td>@{item()?[\'displayName\']}</td><td>@{item()?[\'userPrincipalName\']}</td><td></td></tr>'
                  }
                }
                'HTTP_-_Delete_user': {
                  runAfter: {
                    Append_to_string_variable: [
                      'Succeeded'
                    ]
                  }
                  type: 'Http'
                  inputs: {
                    uri: 'https://graph.microsoft.com/v1.0/users@{item()?[\'id\']}'
                    method: 'DELETE'
                    authentication: {
                      type: 'ManagedServiceIdentity'
                      identity: userAssignedIdentities_LA_Entra_Inactive_Guests_identity_name_resource.id
                      audience: 'https://graph.microsoft.com'
                    }
                  }
                  runtimeConfiguration: {
                    contentTransfer: {
                      transferMode: 'Chunked'
                    }
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
                      '@items(\'For_each\')?[\'signInActivity\']?[\'lastSignInDateTime\']'
                      '@body(\'Get_past_time\')'
                    ]
                  }
                ]
              }
              type: 'If'
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        'Initialize_variable_-_breakLoop': {
          runAfter: {
            'Initialize_variable_-_tableRows': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'breakLoop'
                type: 'boolean'
                value: false
              }
            ]
          }
        }
        Until: {
          actions: {
            'HTTP_-_Get_Guest_users': {
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/users'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                queries: {
                  '$filter': 'userType eq \'Guest\''
                  '$select': 'displayName,userPrincipalName,signInActivity'
                }
                authentication: {
                  type: 'ManagedServiceIdentity'
                  identity: userAssignedIdentities_LA_Entra_Inactive_Guests_identity_name_resource.id
                  audience: 'https://graph.microsoft.com'
                }
              }
              runtimeConfiguration: {
                paginationPolicy: {
                  minimumItemCount: 100
                }
                contentTransfer: {
                  transferMode: 'Chunked'
                }
              }
            }
            'Set_variable_-_breakLoop_true': {
              runAfter: {
                'HTTP_-_Get_Guest_users': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'breakLoop'
                value: true
              }
            }
            'Delay_-_5_seconds': {
              runAfter: {
                'HTTP_-_Get_Guest_users': [
                  'Succeeded'
                ]
              }
              type: 'Wait'
              inputs: {
                interval: {
                  count: 5
                  unit: 'Second'
                }
              }
            }
          }
          runAfter: {
            'Initialize_variable_-_breakLoop': [
              'Succeeded'
            ]
          }
          expression: '@equals(variables(\'breakLoop\'),true)'
          limit: {
            count: 60
            timeout: 'PT1H'
          }
          type: 'Until'
        }
        'Terminate_-_REMOVE_THIS_IF_YOU_REALLY_WANT_TO_RUN_THIS_FLOW': {
          runAfter: {}
          type: 'Terminate'
          inputs: {
            runStatus: 'Cancelled'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {}
      }
    }
  }
}

resource workflows_LA_Entra_Report_Inactive_Guests_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_LA_Entra_Report_Inactive_Guests_name
  location: 'westeurope'
  tags: {
    Playbook: 'LA-Entra-Inactive-Guests'
    createdBy: 'A'
    createdOn: '26.01.2025'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/DEV-Entra-Inactive-Users/providers/Microsoft.ManagedIdentity/userAssignedIdentities/LA-Entra-Inactive-Guests-identity': {}
    }
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
            interval: 4
            frequency: 'Week'
          }
          evaluatedRecurrence: {
            interval: 4
            frequency: 'Week'
          }
          type: 'Recurrence'
        }
      }
      actions: {
        Get_past_time: {
          runAfter: {}
          type: 'Expression'
          kind: 'GetPastTime'
          inputs: {
            interval: 12
            timeUnit: 'Month'
          }
        }
        'Initialize_variable_-_tableRows': {
          runAfter: {
            Get_past_time: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'tableRows'
                type: 'string'
                value: '@null'
              }
            ]
          }
        }
        Parse_JSON: {
          runAfter: {
            Until: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'HTTP_-_Get_Guest_users\')'
            schema: {
              type: 'object'
              properties: {
                statusCode: {
                  type: 'integer'
                }
                headers: {
                  type: 'object'
                  properties: {
                    'Cache-Control': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Transfer-Encoding': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    Vary: {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Strict-Transport-Security': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'request-id': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'client-request-id': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'x-ms-ags-diagnostic': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'x-ms-resource-unit': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'OData-Version': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    Date: {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Content-Type': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    'Content-Length': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                  }
                }
                body: {
                  type: 'object'
                  properties: {
                    '@@odata.context': {
                      type: [
                        'string'
                        'null'
                      ]
                    }
                    value: {
                      type: 'array'
                      items: {
                        type: 'object'
                        properties: {
                          displayName: {
                            type: [
                              'string'
                              'null'
                            ]
                          }
                          userPrincipalName: {
                            type: [
                              'string'
                              'null'
                            ]
                          }
                          id: {
                            type: [
                              'string'
                              'null'
                            ]
                          }
                          signInActivity: {
                            type: 'object'
                            properties: {
                              lastSignInDateTime: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastSignInRequestId: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastNonInteractiveSignInDateTime: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastNonInteractiveSignInRequestId: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastSuccessfulSignInDateTime: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                              lastSuccessfulSignInRequestId: {
                                type: [
                                  'string'
                                  'null'
                                ]
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        For_each: {
          foreach: '@outputs(\'Parse_JSON\')?[\'body\']?[\'value\']'
          actions: {
            Condition: {
              actions: {
                Append_to_string_variable: {
                  runAfter: {
                    Convert_time_zone: [
                      'Succeeded'
                    ]
                  }
                  type: 'AppendToStringVariable'
                  inputs: {
                    name: 'tableRows'
                    value: '<tr><td>@{item()?[\'displayName\']}</td><td>@{item()?[\'userPrincipalName\']}</td><td>@{item()?[\'id\']}</td><td>@{body(\'Convert_time_zone\')}</td></tr>'
                  }
                }
                Convert_time_zone: {
                  type: 'Expression'
                  kind: 'ConvertTimeZone'
                  inputs: {
                    baseTime: '@item()?[\'signInActivity\']?[\'lastSignInDateTime\']'
                    sourceTimeZone: 'UTC'
                    destinationTimeZone: 'FLE Standard Time'
                    formatString: ' dd.MM.yyyy HH:mm'
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
                      '@items(\'For_each\')?[\'signInActivity\']?[\'lastSignInDateTime\']'
                      '@body(\'Get_past_time\')'
                    ]
                  }
                ]
              }
              type: 'If'
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        'Compose_-_Message': {
          runAfter: {
            For_each: [
              'Succeeded'
            ]
          }
          type: 'Compose'
          inputs: '<table style="width:100%; border-collapse: collapse; border: 1px solid #ddd; font-family: Arial, sans-serif;">\n  <thead>\n    <tr style="background-color: #f2f2f2; color: #333;">\n      <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">Display Name</th>\n      <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">User Principal Name</th>\n<th style="border: 1px solid #ddd; padding: 8px; text-align: left;">ID</th>\n      <th style="border: 1px solid #ddd; padding: 8px; text-align: left;">Last Interractive Sign-In</th>\n    </tr>\n  </thead>\n  <tbody>\n  @{variables(\'tableRows\')}\n  </tbody>\n</table>'
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
                groupId: 'e719229b-c331-4665-b020-0f19b0b90de3'
                channelId: '19:OQjg6xEIVLQvxNa2G1LMrymaPl7UifBZcOFxEZkkNE41@thread.tacv2'
              }
              messageBody: '<p class="editor-paragraph">@{outputs(\'Compose_-_Message\')}</p>'
              subject: 'Inactive user report'
            }
            path: '/beta/teams/conversation/message/poster/@{encodeURIComponent(\'User\')}/location/@{encodeURIComponent(\'Channel\')}'
          }
        }
        'Initialize_variable_-_breakLoop': {
          runAfter: {
            'Initialize_variable_-_tableRows': [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'breakLoop'
                type: 'boolean'
                value: false
              }
            ]
          }
        }
        Until: {
          actions: {
            'HTTP_-_Get_Guest_users': {
              type: 'Http'
              inputs: {
                uri: 'https://graph.microsoft.com/v1.0/users'
                method: 'GET'
                headers: {
                  ConsistencyLevel: 'eventual'
                }
                queries: {
                  '$filter': 'userType eq \'Guest\''
                  '$select': 'displayName,userPrincipalName,signInActivity'
                }
                authentication: {
                  type: 'ManagedServiceIdentity'
                  identity: userAssignedIdentities_LA_Entra_Inactive_Guests_identity_name_resource.id
                  audience: 'https://graph.microsoft.com'
                }
              }
              runtimeConfiguration: {
                paginationPolicy: {
                  minimumItemCount: 100
                }
                contentTransfer: {
                  transferMode: 'Chunked'
                }
              }
            }
            'Set_variable_-_breakLoop_true': {
              runAfter: {
                'HTTP_-_Get_Guest_users': [
                  'Succeeded'
                ]
              }
              type: 'SetVariable'
              inputs: {
                name: 'breakLoop'
                value: true
              }
            }
            'Delay_-_5_seconds': {
              runAfter: {
                'HTTP_-_Get_Guest_users': [
                  'Failed'
                  'Skipped'
                  'TimedOut'
                ]
              }
              type: 'Wait'
              inputs: {
                interval: {
                  count: 5
                  unit: 'Second'
                }
              }
            }
          }
          runAfter: {
            'Initialize_variable_-_breakLoop': [
              'Succeeded'
            ]
          }
          expression: '@equals(variables(\'breakLoop\'),true)'
          limit: {
            count: 60
            timeout: 'PT1H'
          }
          type: 'Until'
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          teams: {
            id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/teams'
            connectionId: connections_LA_Entra_Inactive_Guests_teams_name_resource.id
            connectionName: 'teams'
          }
        }
      }
    }
  }
}
