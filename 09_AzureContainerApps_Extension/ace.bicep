targetScope = 'subscription'
param location string
param rgName string
param customLocationId string
param connectedEnvironmentName string

resource rg_aca 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name:     rgName
  location: location  
}

module connectedEnvironment 'container-env.bicep' = {
  scope: rg_aca
  name: connectedEnvironmentName
  params: {
    location:         location
    name:             connectedEnvironmentName
    customLocationId: customLocationId
  }
}
