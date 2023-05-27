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
      purpose: 'Pool-Compute'
      name: avdComputeObjectsRg
      location: avdHostPoolMetadataLocation
      enableDefaultTelemetry: false
      
  }
  rg3: {
    purpose: 'Storage'
    name: avdStorageObjectsRg
    location: avdHostPoolMetadataLocation
    enableDefaultTelemetry: false
    
  }
  rg4: {
    purpose: 'Monitoring'
    name: avdMonitoringRg
    location: avdHostPoolMetadataLocation
    enableDefaultTelemetry: false
    
  }
}

var varTimeZones = {
  australiacentral: 'AUS Eastern Standard Time'
  australiacentral2: 'AUS Eastern Standard Time'
  australiaeast: 'AUS Eastern Standard Time'
  australiasoutheast: 'AUS Eastern Standard Time'
  brazilsouth: 'E. South America Standard Time'
  brazilsoutheast: 'E. South America Standard Time'
  canadacentral: 'Eastern Standard Time'
  canadaeast: 'Eastern Standard Time'
  centralindia: 'India Standard Time'
  centralus: 'Central Standard Time'
  chinaeast: 'China Standard Time'
  chinaeast2: 'China Standard Time'
  chinanorth: 'China Standard Time'
  chinanorth2: 'China Standard Time'
  eastasia: 'China Standard Time'
  eastus: 'Eastern Standard Time'
  eastus2: 'Eastern Standard Time'
  francecentral: 'Central Europe Standard Time'
  francesouth: 'Central Europe Standard Time'
  germanynorth: 'Central Europe Standard Time'
  germanywestcentral: 'Central Europe Standard Time'
  japaneast: 'Tokyo Standard Time'
  japanwest: 'Tokyo Standard Time'
  jioindiacentral: 'India Standard Time'
  jioindiawest: 'India Standard Time'
  koreacentral: 'Korea Standard Time'
  koreasouth: 'Korea Standard Time'
  northcentralus: 'Central Standard Time'
  northeurope: 'GMT Standard Time'
  norwayeast: 'Central Europe Standard Time'
  norwaywest: 'Central Europe Standard Time'
  southafricanorth: 'South Africa Standard Time'
  southafricawest: 'South Africa Standard Time'
  southcentralus: 'Central Standard Time'
  southindia: 'India Standard Time'
  southeastasia: 'Singapore Standard Time'
  swedencentral: 'Central Europe Standard Time'
  switzerlandnorth: 'Central Europe Standard Time'
  switzerlandwest: 'Central Europe Standard Time'
  uaecentral: 'Arabian Standard Time'
  uaenorth: 'Arabian Standard Time'
  uksouth: 'GMT Standard Time'
  ukwest: 'GMT Standard Time'
  usdodcentral: 'Central Standard Time'
  usdodeast: 'Eastern Standard Time'
  usgovarizona: 'Mountain Standard Time'
  usgoviowa: 'Central Standard Time'
  usgovtexas: 'Central Standard Time'
  usgovvirginia: 'Eastern Standard Time'
  westcentralus: 'Mountain Standard Time'
  westeurope: 'Central Europe Standard Time'
  westindia: 'India Standard Time'
  westus: 'Pacific Standard Time'
  westus2: 'Pacific Standard Time'
  westus3: 'Mountain Standard Time'
}
@description('Do not modify, used to set unique value for resource deployment.')

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
