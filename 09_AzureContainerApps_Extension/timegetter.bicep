targetScope = 'subscription'

param location string
param acrName string
param rgName string
param connectedEnvironmentName string

resource rg_aca 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: rgName  
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  scope: rg_aca
  name: acrName
}

resource connectedEnvironment 'Microsoft.App/connectedEnvironments@2022-10-01' existing = {
  scope: rg_aca
  name: connectedEnvironmentName
}

module timeBackContainerApp 'container-app.bicep' =  {
  scope: rg_aca
  name: 'time-backend'
  params: {
    containerAppEnvironmentId: connectedEnvironment.id
    containerImage: '${acrName}.azurecr.io/timebackend:latest'
    customLocationId: connectedEnvironment.extendedLocation.name
    containerPort: 80
    location: location
    name: 'time-backend'   
    registry: '${acrName}.azurecr.io'
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username    
    useExternalIngress: true    
    envVars: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
      }
    ]
  }
}

module timeFrontContainerApp 'container-app.bicep' =  {
  scope: rg_aca
  name: 'time-frontend'
  params: {
    containerAppEnvironmentId: connectedEnvironment.id         
    containerImage: '${acrName}.azurecr.io/timefrontend:latest'
    customLocationId: connectedEnvironment.extendedLocation.name
    containerPort: 80
    location: location
    name: 'time-frontend'   
    registry: '${acrName}.azurecr.io'
    registryPassword: acr.listCredentials().passwords[0].value
    registryUsername: acr.listCredentials().username
    useExternalIngress: true            
    envVars: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
      }
      {
        name: 'API__api_address'
        value: 'https://${timeBackContainerApp.outputs.fqdn}/time'
      }
    ]
  }
}
