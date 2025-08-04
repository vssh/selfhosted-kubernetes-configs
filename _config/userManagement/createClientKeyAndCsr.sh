#!/bin/bash

KEYS_FOLDER=user_keys
USER=
GROUP=

if [[ -z $USER || -z $GROUP || $KEYS_FOLDER ]]; then
  echo "Set user and group"
  exit 1
fi

echo "Remember to check there are no existing user, context or CSR with the same name..."

mkdir $KEYS_FOLDER
openssl genrsa -out $KEYS_FOLDER/$USER.key 2048
openssl req -new -key $KEYS_FOLDER/$USER.key -out $KEYS_FOLDER/$USER.csr -subj "/CN=${USER}/O=${GROUP}"

cat << EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER
spec:
  groups:
  - system:authenticated
  request: $(cat ${KEYS_FOLDER}/${USER}.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
   - client auth
EOF

kubectl certificate approve $USER
kubectl get csr

kubectl get csr $USER -o jsonpath='{.status.certificate}'  | base64 -d > $KEYS_FOLDER/$USER.crt

kubectl config set-credentials $USER --client-key=$KEYS_FOLDER/$USER.key --client-certificate=$KEYS_FOLDER/$USER.crt --embed-certs=true
kubectl config set-context $USER --cluster=default --user=$USER
