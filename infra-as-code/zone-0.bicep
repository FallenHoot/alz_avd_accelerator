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
module networkSecurityGroupAVD '../carml/0.10.0/modules/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  scope: resourceGroup(avdNetworkObjectsRg)
  name: '${uniqueString(deployment().name)}-Networking-NSG'
  params: {
    // Required parameters
    name: avdNetworksecurityGroup
    lock: 'CanNotDelete'
    location: avdSessionHostLocation
    securityRules: [
      {
          name: 'AVDServiceTraffic'
          properties: {
              priority: 100
              access: 'Allow'
              description: 'Session host traffic to AVD control plane'
              destinationAddressPrefix: 'WindowsVirtualDesktop'
              direction: 'Outbound'
              sourcePortRange: '*'
              destinationPortRange: '443'
              protocol: 'Tcp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
      {
          name: 'AzureCloud'
          properties: {
              priority: 110
              access: 'Allow'
              description: 'Session host traffic to Azure cloud services'
              destinationAddressPrefix: 'AzureCloud'
              direction: 'Outbound'
              sourcePortRange: '*'
              destinationPortRange: '8443'
              protocol: 'Tcp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
      {
          name: 'AzureMonitor'
          properties: {
              priority: 120
              access: 'Allow'
              description: 'Session host traffic to Azure Monitor'
              destinationAddressPrefix: 'AzureMonitor'
              direction: 'Outbound'
              sourcePortRange: '*'
              destinationPortRange: '443'
              protocol: 'Tcp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
      {
          name: 'AzureMarketPlace'
          properties: {
              priority: 130
              access: 'Allow'
              description: 'Session host traffic to Azure Monitor'
              destinationAddressPrefix: 'AzureFrontDoor.Frontend'
              direction: 'Outbound'
              sourcePortRange: '*'
              destinationPortRange: '443'
              protocol: 'Tcp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
      {
          name: 'WindowsActivationKMS'
          properties: {
              priority: 140
              access: 'Allow'
              description: 'Session host traffic to Windows license activation services'
              destinationAddressPrefix: '23.102.135.246'
              direction: 'Outbound'
              sourcePortRange: '*'
              destinationPortRange: '1688'
              protocol: 'Tcp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
      {
          name: 'AzureInstanceMetadata'
          properties: {
              priority: 150
              access: 'Allow'
              description: 'Session host traffic to Azure instance metadata'
              destinationAddressPrefix: '169.254.169.254'
              direction: 'Outbound'
              sourcePortRange: '*'
              destinationPortRange: '80'
              protocol: 'Tcp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
      {
          name: 'RDPShortpath'
          properties: {
              priority: 150
              access: 'Allow'
              description: 'Session host traffic to Azure instance metadata'
              destinationAddressPrefix: 'VirtualNetwork'
              direction: 'Inbound'
              sourcePortRange: '*'
              destinationPortRange: '3390'
              protocol: 'Udp'
              sourceAddressPrefix: 'VirtualNetwork'
          }
      }
  ]
  enableDefaultTelemetry: false
  }
}

module routeTableAvd '../carml/0.10.0/modules/Microsoft.Network/routeTables/deploy.bicep' = {
  scope: resourceGroup(avdNetworkObjectsRg)
  name: '${uniqueString(deployment().name)}-Networking-RT'
  params: {
    // Required parameters
    name: avdRouteTable
    lock: 'CanNotDelete'
    location: avdSessionHostLocation
    routes: [
      {
        name: 'AVDServiceTraffic'
        properties: {
          addressPrefix: 'WindowsVirtualDesktop'
          hasBgpOverride: true
          nextHopType: 'Internet'
        }
      }
    ]
    enableDefaultTelemetry: false
  }
}

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
    lock: 'CanNotDelete'
    subnets: [
      {
        addressPrefix: vNetworkAvdSubnetAddressPrefix
        name: avdVnetworkSubnetName
        networkSecurityGroupId: networkSecurityGroupAVD.outputs.resourceId
        routeTableId: routeTableAvd.outputs.resourceId
    
      }
    ]
  }
}
