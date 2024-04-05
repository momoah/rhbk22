oc patch storageclass lvms-vg1 -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

cat > /tmp/keycloak.ext << EOF
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = keycloak.local.momolab.io
DNS.2 = keycloak-rhbk1.apps.sno2.local.momolab.io
DNS.3 = keycloak-rhbk2.apps.sno2.local.momolab.io
DNS.4 = keycloak-rhbk.apps.sno2.local.momolab.io
EOF
 
openssl req -x509 \
    -sha384 -days 9999 \
    -nodes \
    -newkey rsa:3072 \
    -subj "/CN=KeyCloak Cert Authority" \
    -keyout /tmp/ocp_ca.key -out /tmp/ocp_ca.pem 

openssl req -new \
    -nodes \
    -newkey rsa:3072 \
    -subj "/CN=Keycloak Transparent Proxy" \
    -keyout /tmp/keycloak.key -out /tmp/keycloak.csr
 
openssl x509 -req \
    -in /tmp/keycloak.csr \
    -CA /tmp/ocp_ca.pem -CAkey /tmp/ocp_ca.key \
    -CAcreateserial -out /tmp/keycloak.pem \
    -days 9999 \
    -sha384 -extfile /tmp/keycloak.ext
 
cat /tmp/keycloak.pem  > /tmp/certificate.pem
cat /tmp/ocp_ca.pem  >> /tmp/certificate.pem
cat /tmp/keycloak.key > /tmp/key.pem


 
sudo cp /tmp/ocp_ca.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust

oc new-project rhbk

oc create secret tls keycloak-tls-secret -n rhbk --cert /tmp/certificate.pem --key /tmp/key.pem 

keytool -import -alias root-ca -keystore /tmp/truststore.jks -file /tmp/ocp_ca.pem -storepass changeit

oc create secret generic keycloak-truststore-secret -n rhbk --from-file=/tmp/truststore.jks

