param location string
param name string
param customLocationId string

resource containerEnvironment 'Microsoft.App/connectedEnvironments@2022-10-01' = {  
  name: name
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: customLocationId
  }
  properties: {
    
  }
}

output id string = containerEnvironment.id
