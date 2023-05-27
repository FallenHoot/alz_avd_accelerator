targetScope = 'subscription'

// ============ //
//  AVD Params  //
// =========== //
@description('AVD Subscription ID (Default: XXXX-XXXXX-XXXXXXX-XXXX)')
param avdSubscriptionID string = 'a7693725-2adf-4eff-98eb-fc941246426d'
primarydomain MngEnvMCAP398668.onmicrosoft.com

@description('Location where to deploy AVD management plane. (Default: westeurope)')
param avdHostPoolMetadataLocation string = 'westeurope'
@description('Location where to deploy Host Pool/VM Services. (Default: eastus2)')
param avdSessionHostLocation string = 'norwayeast'
@description('Required. AVD Host Pool Type. Pooled or Personal ID, multiple subscriptions scenario. (Default: Pooled )')
param avdHostPoolType string = 'Pooled'
@description('Required. Breadth-first load balancing distributes new user sessions across all available session hosts in the host pool. Depth-first load balancing distributes new user sessions to an available session host with the highest number of connections but has not reached its maximum session limit threshold. (Default: Breadth-first )')
param avdLoadBalancingAlgorithm string = 'BreadthFirst'
@description('Required. Automatic assignment – The service will select an available host and assign it to an user. Direct assignment – Admin selects a specific host to assign to an user. (Default: Automatic )')
param avdAssignmentType string = 'Automatic'
@description('Required. HostPool Name. (Default: alzavdaccelerator )')
@minLength(1)
param avdHostPoolName string = 'alzavdaccelerator'
@description('Required. The type of preferred application group type, default to Desktop or Remote App (Rail) Group.. (Default: Desktop )')
param avdPreferredAppGroupType string = 'Desktop'
@description('Required. Maximum number of sessions. Max = 9999; Min = 1. (Default: 1 )')
@minValue(1)
param avdSessionLimit int = 1


//SessionHost
@description('Domain name. (Default: microsoft.com)')
param primarydomain string = 'MngEnvMCAP398668.onmicrosoft.com'
@description('OS DiskType (Default: StandardSSD_LRS)')
param vmDiskType string = 'StandardSSD_LRS'
@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string = 'a7693725-2adf-4eff-98eb-fc941246426d'

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


// ================== //
// DO NOT EDIT BELOW //
// ================= //
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

// Call on the hotspool.
resource getHostPool 'Microsoft.DesktopVirtualization/hostPools@2019-12-10-preview' existing = {
  name: avdHostPoolName
  scope: resourceGroup('${workloadSubsId}', '${avdComputeObjectsRg}')
}
// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool './registerSessionHostsOnHopstPool.bicep' = [for i in range(1, sessionHostsCount): {
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  name: 'HP-Join-${padLeft((i + sessionHostCountIndex), 3, '0')}-to-HP-${time}'
  params: {
      location: sessionHostLocation
      hostPoolToken: hostPoolToken
      name: '${sessionHostNamePrefix}-${padLeft((i + sessionHostCountIndex), 3, '0')}'
      hostPoolName: avdHostPoolName
      avdAgentPackageLocation: avdAgentPackageLocation
  }
  dependsOn: [
      sessionHosts
      sessionHostsMonitoringWait
      configureFsLogixForAvdHosts
  ]
}]
module sessionhost '../carml/0.10.0/modules/Microsoft.DesktopVirtualization/hostpools/deploy.bicep' = {
  scope: resourceGroup('${workloadSubsId}', '${avdComputeObjectsRg}')
  name: '${uniqueString(deployment().name)}-SessionHost'
  params: {
    // Required parameters
    name: avdHostPoolName
    preferredAppGroupType: avdPreferredAppGroupType
    agentUpdate: {
      maintenanceWindows: [
        {
          dayOfWeek: 'Friday'
          hour: 7
        }
        {
          dayOfWeek: 'Saturday'
          hour: 8
        }
      ]
      maintenanceWindowTimeZone: varTimeZones[avdSessionHostLocation]
      type: 'Scheduled'
      useSessionHostLocalTime: false
    }
    customRdpProperty: 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2;'
    description: 'ALZ AVD POC'
    friendlyName: 'AVDv2'
    type: avdHostPoolType
    loadBalancerType: avdLoadBalancingAlgorithm
    location: avdHostPoolMetadataLocation
    lock: 'CanNotDelete'
    maxSessionLimit: avdSessionLimit
    personalDesktopAssignmentType: avdHostPoolType == 'Personal' ? '': avdAssignmentType
    hostPoolToken: getHostPool.properties.registrationInfo.token
    vmTemplate: {
      customImageId: '<customImageId>'
      domain: 'domainname.onmicrosoft.com'
      galleryImageOffer: 'office-365'
      galleryImagePublisher: 'microsoftwindowsdesktop'
      galleryImageSKU: '20h1-evd-o365pp'
      imageType: 'Gallery'
      imageUri: '<imageUri>'
      namePrefix: 'avdv2'
      osDiskType: 'StandardSSD_LRS'
      useManagedDisks: true
      vmSize: {
        cores: 2
        id: 'Standard_D2s_v3'
        ram: 8
      }
    }
  }
}
