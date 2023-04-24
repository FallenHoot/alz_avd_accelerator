@description('AVD Subscription ID (Default: XXXX-XXXXX-XXXXXXX-XXXX)')
param avdSubscriptionID string = 'a7693725-2adf-4eff-98eb-fc941246426d'
param time string = utcNow()


module rg '../carml/0.10.0/modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  scope: subscription(avdSubscriptionID)
  name: 'rg-${time}'
  params: {
    // Required parameters
    name: 'test9845'
  }
}
