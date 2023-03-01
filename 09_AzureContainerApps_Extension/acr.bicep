targetScope = 'subscription'

param location string
param rgName string

param acrManagedIdentity string = 'None'

// ACR for images
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = toLower('acr${uniqueString(subscription().id,rgName)}')

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

resource rg_acr 'Microsoft.Resources/resourceGroups@2021-04-01' existing =  {
  name: rgName  
}

module acr 'container-registry.bicep' = {
  scope: rg_acr
  name: acrName
  params: {
    acrName: acrName
    acrSku: acrSku
    location: location
    adminUserEnabled: true
    anonymousPullEnabled: false
    managedIdentity: acrManagedIdentity
  }
}

@description('Output the login server property for later use')
output loginServer string = acr.outputs.loginServer

// Managed identity for ACA doesn't support registry pulls yet
output admin string = acr.outputs.admin
output password string = acr.outputs.password
