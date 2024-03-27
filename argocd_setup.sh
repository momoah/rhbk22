#!/bin/bash

oc adm policy add-cluster-role-to-user cluster-admin admin
oc adm groups new cluster-admins
oc adm groups add-users cluster-admins admin
oc create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user admin


cat > ./openshift-gitops-operator-namespace.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-gitops-operator
EOF

oc apply -f ./openshift-gitops-operator-namespace.yaml


cat > ./openshift-gitops-operatorgroup.yaml << EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-gitops-operator-mgo
  namespace: openshift-gitops-operator
spec:
  upgradeStrategy: Default
status:
  namespaces:
  - ""
EOF


oc apply -f ./openshift-gitops-operatorgroup.yaml

cat > ./openshift-gitops-operator-subscription.yaml << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-gitops-operator
spec:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  #  startingCSV: openshift-gitops-operator.v1.11.1

EOF

oc apply -f ./openshift-gitops-operator-subscription.yaml

cat > ./openshift-gitops-instance.yaml << EOF
apiVersion: argoproj.io/v1beta1
kind: ArgoCD
metadata:
  finalizers:
  - argoproj.io/finalizer
  name: openshift-gitops
  namespace: openshift-gitops
  ownerReferences:
  - apiVersion: pipelines.openshift.io/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: GitopsService
    name: cluster
  uid: 12345678-abcd-1234-abcd-123456789abc
spec:
  applicationSet:
    resources:
      limits:
        cpu: "2"
        memory: 1Gi
      requests:
        cpu: 250m
        memory: 512Mi
    webhookServer:
      ingress:
        enabled: false
      route:
        enabled: false
  controller:
    processors: {}
    resources:
      limits:
        cpu: "2"
        memory: 2Gi
      requests:
        cpu: 250m
        memory: 1Gi
    sharding: {}
  grafana:
    enabled: false
    ingress:
      enabled: false
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 250m
        memory: 128Mi
    route:
      enabled: false
  ha:
    enabled: false
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 250m
        memory: 128Mi
  initialSSHKnownHosts: {}
  monitoring:
    enabled: false
  notifications:
    enabled: false
  prometheus:
    enabled: false
    ingress:
      enabled: false
    route:
      enabled: false
  rbac:
    defaultPolicy: ""
    policy: |
      g, system:cluster-admins, role:admin
      g, cluster-admins, role:admin
    scopes: '[groups]'
  redis:
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 250m
        memory: 128Mi
  repo:
    resources:
      limits:
        cpu: "1"
        memory: 1Gi
      requests:
        cpu: 250m
        memory: 256Mi
  resourceExclusions: |
    - apiGroups:
      - tekton.dev
      clusters:
      - '*'
      kinds:
      - TaskRun
      - PipelineRun
  server:
    autoscale:
      enabled: false
    grpc:
      ingress:
        enabled: false
    ingress:
      enabled: false
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 125m
        memory: 128Mi
    route:
      enabled: true
    service:
      type: ""
  sso:
    dex:
      openShiftOAuth: true
      resources:
        limits:
          cpu: 500m
          memory: 256Mi
        requests:
          cpu: 250m
          memory: 128Mi
    provider: dex
  tls:
    ca: {}
EOF

oc apply -f ./openshift-gitops-instance.yaml


cat > ./openshift-gitops-application-controller-cluster-admin.yaml << EOF

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: openshift-gitops-application-controller-cluster-admin
  namespace: openshift-gitops
subjects:
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF

oc apply -f ./openshift-gitops-application-controller-cluster-admin.yaml 



