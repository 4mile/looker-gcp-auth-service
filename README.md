# looker-gcp-auth-service

To install locally
```
nvm use 16
yarn install
```

To run locally
```
node index.js
```

To build Docker image locally
```
docker build -t helloworld .
```

To run Docker image
```
docker run -d -p 3000:3000 --name helloworld--app helloworld
```


TODOS:
- manually enable : Cloud Resource Manager API
- Add terraform service account (https://gmusumeci.medium.com/how-to-create-a-service-account-for-terraform-in-gcp-google-cloud-platform-f75a0cf918d1)
  - manually add perms
    - Cloud Run Admin
    - Compute Admin
    - Organization Administrator
    - Service Directory Admin
    - Storage Admin
- Configure Cloudbuild Service Account to access Github (https://medium.com/geekculture/continuous-integration-gcp-cloud-build-with-terraform-4b8ffc709c60) - under Connect Repository
  - manually add roles:
    - Secret Manager Secret Accesssor


####### TODO
- add github credentials
- fix terraform 
- talk to Eric
  - order of operations on deployment