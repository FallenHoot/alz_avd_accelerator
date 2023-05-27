targetScope = 'subscription'
// ======== //
// Boolens //
// ======== //

// ============ //
//  AVD Params  //
// =========== //

@description('Location where to deploy AVD management plane. (Default: eastus2)')
param avdHostPoolMetadataLocation string = 'westeurope'
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

// ====================== //
// Resource Group Naming  //
// ====================== //
@maxLength(90)
@description('AVD service resources resource group custom name. (Default: rg-avd-use2-app1-service-objects)')
param avdServiceObjectsRg string = 'rg-avd-use2-app1-service-objects'

// Hostpool w/o session host
module hostpools '../carml/0.10.0/modules/Microsoft.DesktopVirtualization/hostpools/deploy.bicep' = {
  scope: resourceGroup(avdServiceObjectsRg)
  name: '${uniqueString(deployment().name)}-HostPool'
  params: {
    // Required parameters
    name: avdHostPoolName
    preferredAppGroupType: avdPreferredAppGroupType
    customRdpProperty: 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2;'
    description: 'ALZ AVD POC'
    friendlyName: 'AVDv2'
    type: avdHostPoolType
    loadBalancerType: avdLoadBalancingAlgorithm
    location: avdHostPoolMetadataLocation
    lock: 'CanNotDelete'
    maxSessionLimit: avdSessionLimit
    personalDesktopAssignmentType: avdHostPoolType == 'Personal' ? '': avdAssignmentType
  }
}
