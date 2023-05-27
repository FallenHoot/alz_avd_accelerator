targetScope = 'subscription'
// ======== //
// Boolens //
// ======== //
@description('Optional. Create new virtual network. (Default: true)')
param createAvdVnet bool = true

// ============ //
//  AVD Params  //
// =========== //
@description('AVD Subscription ID (Default: XXXX-XXXXX-XXXXXXX-XXXX)')
param avdSubscriptionID string = 'a7693725-2adf-4eff-98eb-fc941246426d'
@description('Location where to deploy AVD management plane. (Default: eastus2)')
param avdHostPoolMetadataLocation string = 'westeurope'
@description('Location where to deploy Host Pool/VM Services. (Default: eastus2)')
param avdSessionHostLocation string = 'norwayeast'

// ====================== //
// Resource Group Naming  //
// ====================== //
@maxLength(90)
@description('AVD service resources resource group custom name. (Default: rg-avd-use2-app1-service-objects)')
param avdServiceObjectsRg string = 'rg-avd-use2-app1-service-objects'
@maxLength(90)
@description('AVD network resources resource group custom name. (Default: rg-avd-use2-app1-network)')
param avdNetworkObjectsRg string = 'rg-avd-use2-app1-network'
@maxLength(90)
@description('AVD network resources resource group custom name. (Default: rg-avd-use2-app1-pool-compute)')
param avdComputeObjectsRg string = 'rg-avd-use2-app1-pool-compute'
@maxLength(90)
@description('AVD network resources resource group custom name. (Default: rg-avd-use2-app1-storage)')
param avdStorageObjectsRg string = 'rg-avd-use2-app1-storage'
@maxLength(90)
@description('AVD monitoring resource group custom name. (Default: rg-avd-use2-app1-monitoring)')
param avdMonitoringRg string = 'rg-avd-use2-app1-monitoring'

// ================ //
// Network Params  //
// =============== //
// If createAvdVnet = True edit Network Params
@description('AVD virtual network address prefixes. (Default: 10.10.0.0/23)')
param avdVnetworkAddressPrefixes string = '10.10.0.0/23'
@description('AVD virtual network subnet address prefix. (Default: 10.10.0.0/24)')
param vNetworkAvdSubnetAddressPrefix string = '10.10.0.0/24'
@maxLength(64)
@description('Optional. AVD virtual network custom name. (Default: vnet-avd-use2-app1-001)')
param avdVnetworkName string = 'vnet-avd-use2-app1-001'
@maxLength(80)
@description('AVD virtual network subnet custom name. (Default: snet-avd-use2-app1-001)')
param avdVnetworkSubnetName string = 'snet-avd-use2-app1-001'
@maxLength(80)
@description('Optional. AVD network security group custom name. (Default: nsg-avd-use2-app1-001)')
param avdNetworksecurityGroup string = 'nsg-avd-use2-app1-001'
@maxLength(80)
@description('Optional. AVD route table custom name. (Default: route-avd-use2-app1-001)')
param avdRouteTable string = 'route-avd-use2-app1-001'


// ================== //
// DO NOT EDIT BELOW //
// ================= //
var ResourceGroups  = {
//Exclude NetworkingRG incase end user already has
  rg1: {
      purpose: 'Service-Objects'
      name: avdServiceObjectsRg
      location: avdHostPoolMetadataLocation
      enableDefaultTelemetry: false
  }
  rg2: {
      purpose: 'Session-Compute'
      name: avdComputeObjectsRg
      location: avdSessionHostLocation
      enableDefaultTelemetry: false
      
  }
  rg3: {
    purpose: 'Storage'
    name: avdStorageObjectsRg
    location: avdSessionHostLocation
    enableDefaultTelemetry: false
    
  }
  rg4: {
    purpose: 'Monitoring'
    name: avdMonitoringRg
    location: avdSessionHostLocation
    enableDefaultTelemetry: false
    
  }
}

// ======== //
// Modules //
// ======= //

// Resource Groups
module basicResourceGroups '../carml/0.10.0/modules/Microsoft.Resources/resourceGroups/deploy.bicep' = [for rg in items(ResourceGroups): {
  scope: subscription(avdSubscriptionID)
  name: '${uniqueString(deployment().name)}-${rg.value.name}'
  params: {
    // Required parameters
    name: rg.value.name
    location: rg.value.location
    enableDefaultTelemetry: false
  }
}]

 module baselineNetworkResourceGroup '../carml/0.10.0/modules/Microsoft.Resources/resourceGroups/deploy.bicep' = if (createAvdVnet) {
   scope: subscription(avdSubscriptionID)
   name: '${uniqueString(deployment().name)}-${avdNetworkObjectsRg}'
   params: {
       name: avdNetworkObjectsRg
       location: avdSessionHostLocation
       enableDefaultTelemetry: false
   }
 }

//Networking
module virtualNetworks '../carml/0.10.0/modules/Microsoft.Network/virtualNetworks/deploy.bicep' =  if (createAvdVnet) {
  scope: resourceGroup(avdNetworkObjectsRg)
  name: '${uniqueString(deployment().name)}-Networking'
  params: {
    // Required parameters
    addressPrefixes: [
      avdVnetworkAddressPrefixes
    ]
    name: avdVnetworkName
    location: avdSessionHostLocation
    // Non-required parameters
    lock: 'CanNotDelete'
    subnets: [
      {
        addressPrefix: vNetworkAvdSubnetAddressPrefix
        name: avdVnetworkSubnetName
        networkSecurityGroupId: avdNetworksecurityGroup
        routeTableId: avdRouteTable
    
      }
    ]
  }
}
