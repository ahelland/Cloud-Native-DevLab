param location string
param name string
param containerAppEnvironmentId string
param customLocationId string

param containerImage string
param useExternalIngress bool = false
param containerPort int = 80
param registry string
param registryUsername string
@secure()
param registryPassword string
param envVars array = []

resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: name  
  location: location
  extendedLocation: {
    type: 'CustomLocation'    
    name: customLocationId
  }  
  identity: {
    type: 'None'
  }  
  properties: {        
    environmentId: containerAppEnvironmentId
    configuration: {
      secrets: [
        {
          name: 'container-registry-password'
          value: registryPassword
        }
      ]
      registries: [
        {          
          server: registry
          username: registryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
    workloadProfileType: null
  }
}

output fqdn string                       = containerApp.properties.configuration.ingress.fqdn
output customDomainVerificationId string = containerApp.properties.customDomainVerificationId
