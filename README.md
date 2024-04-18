# rhbk22
Install and setup RHBK22 via ArgoCD

## Steps to install

1. Create the TLS secrets in RHBK namespace
```
sh bootstrap/pre-create-keycloak-secrets.sh
```
2. Create ArgoCD instance
```
oc apply -k bootstrap/argocd/
```

This first installs crunchy postgres operator (installed in openshift-operators), then rhbk22 operator (installed in rhbk namespace)
Once you have an ArgoCD instance, login to the ArgoCD instance, and add a new application. 

The content of this application is from
`argocd/mainapp.yaml`


# References
Inspired by https://github.com/AdvancedDevSecOpsWorkshop/workshop/tree/main/bootstrap/infra/keycloak-operator

A good doco on Sync Waves and Resource Hooks:
https://redhat-scholars.github.io/argocd-tutorial/argocd-tutorial/04-syncwaves-hooks.html

https://developers.redhat.com/articles/2023/04/10/how-deploy-single-sign-code-using-gitops

