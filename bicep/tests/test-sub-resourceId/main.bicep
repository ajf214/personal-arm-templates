param logAnalyticsWorkspaceResourceGroupName string = 'rg-bicep-eus-loganalytics'
param logAnalyticsWorkspaceName string = 'la-bicep-eus-01'

var diagnosticSettingName = 'GlobalActivityLog'

// manually constructing the resourceId
var workspaceId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${logAnalyticsWorkspaceResourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}'

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
    name: diagnosticSettingName
    location: 'global'
    properties: {
        workspaceId: workspaceId 
        logs: [
            {
                category: 'Administrative'
                enabled: true                
            }
            {
                category: 'Security'
                enabled: true                
            }
            {
                category: 'ServiceHealth'
                enabled: true                
            }
            {
                category: 'Alert'
                enabled: true                
            }
            {
                category: 'Recommendation'
                enabled: true                
            }
            {
                category: 'Policy'
                enabled: true                
            }
            {
                category: 'Autoscale'
                enabled: true                
            }
            {
                category: 'ResourceHealth'
                enabled: true                
            }
        ]
    }
}