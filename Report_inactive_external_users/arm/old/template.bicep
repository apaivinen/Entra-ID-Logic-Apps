param workflows_LA_Entra_Delete_Inactive_Guests_name string = 'LA-Entra-Delete-Inactive-Guests'
param userAssignedIdentities_LA_Entra_Inactive_Guests_identity_externalid string = '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/DEV-Entra-Inactive-Users/providers/Microsoft.ManagedIdentity/userAssignedIdentities/LA-Entra-Inactive-Guests-identity'

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
          inputs: {
            method: 'GET'
          }
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
                      identity: userAssignedIdentities_LA_Entra_Inactive_Guests_identity_externalid
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
                  identity: userAssignedIdentities_LA_Entra_Inactive_Guests_identity_externalid
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
