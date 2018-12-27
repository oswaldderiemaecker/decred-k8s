#!/bin/bash

show_help(){
    echo "Help"
}

apply(){
  init
  dcrstakepool_update_config
  dcrstakepool_pod=$(kubectl get pods -l app=dcrstakepool-node -l tier=backend -o jsonpath="{.items[0].metadata.name}")

  echo "Updating dcrstakepool deployment"
  kubectl apply -f dcrstakepool-deployment.yaml

  echo "Deleting dcrstakepool pod"
  kubectl delete pod $dcrstakepool_pod

  sleep 30
  dcrstakepool_upload_cert

  echo "Done"
}

dcrstakepool_upload_cert(){
  echo "Processing Certs ..."
  dcrstakepool_pod=$(kubectl get pods -l app=dcrstakepool-node -l tier=backend -o jsonpath="{.items[0].metadata.name}")

  for pod in $(kubectl get pods -l app=stakepoold-node -o jsonpath="{.items[*].metadata.name}")
  do
    echo $pod
    echo "Getting Wallet Certs"
    kubectl cp $pod:/root/.dcrwallet/rpc.cert ./certs/dcrwallet/$pod.cert
    kubectl cp ./certs/dcrwallet/$pod.cert $dcrstakepool_pod:/root/certs/dcrwallet/$pod.cert
    echo "Getting Pool Stake Certs"
    kubectl cp $pod:/root/.stakepoold/rpc.cert ./certs/stakepoold/$pod.cert
    kubectl cp ./certs/stakepoold/$pod.cert $dcrstakepool_pod:/root/certs/stakepoold/$pod.cert
    wallet_certs=$wallet_certs"/root/certs/dcrwallet/$pod.cert "
    stakepool_certs=$stakepool_certs"/root/certs/stakepoold/$pod.cert "
  done
  kubectl delete configmap wallet-certs
  kubectl create configmap wallet-certs --from-literal=certs=$(echo $wallet_certs | sed -e "s/ /,/g")
  kubectl delete configmap stakepool-certs
  kubectl create configmap stakepool-certs --from-literal=certs=$(echo $stakepool_certs | sed -e "s/ /,/g")

  echo "Updating DCRStakepool deployment"
  dcrstakepool_deployment "apply"

  echo "Reloading nginx pod"
  kubectl exec -ti $(kubectl get pods -l app=dcrstakepool-node -l tier=frontend -o jsonpath="{.items[0].metadata.name}") -- sh -c "nginx -s stop ; nginx ; nginx -s reopen"

}

dcrstakepool_update_config(){
  sleep 10
  echo "Processing Wallets Hosts ..."
  stakepoold_node_ips=$(kubectl get pods -l app=stakepoold-node -o jsonpath="{.items[*].status.podIP}" | sed -e "s/ /,/g" )
  kubectl delete configmap wallet-hosts
  kubectl create configmap wallet-hosts --from-literal=hosts=$stakepoold_node_ips

  echo "Getting Wallet Extended Public Key"
  votingwalletextpub=$(kubectl exec -ti $(kubectl get pods -l app=stakepoold-node -o jsonpath="{.items[0].metadata.name}") -c stakepoold -- /bin/bash -c '/go/bin/dcrctl --wallet $TESTNET -u test -P test --rpcserver=$(hostname --ip-address) getmasterpubkey default')

  kubectl delete secret votingwalletextpub
  kubectl create secret generic votingwalletextpub --from-literal=votingextpub=$votingwalletextpub

  echo "Setting Cold Wallet Extended Public Key"
  kubectl delete secret coldwalletextpub
  kubectl create secret generic coldwalletextpub --from-literal=coldwalletextpub=tpubVoda63Jgvu4uD2teFyoKDQih7hYwvjjYfhxLCgCsqbswmXxXKopDNPF5SR3i598ATR55zNDre9MkjR8vvSC2SzM1snJYG5obkagZJyBcvgi

  # Generating wallet-certs and stakepool-certs names
  for pod in $(kubectl get pods -l app=stakepoold-node -o jsonpath="{.items[*].metadata.name}")
  do
    echo $pod
    wallet_certs=$wallet_certs"/root/certs/dcrwallet/$pod.cert "
    stakepool_certs=$stakepool_certs"/root/certs/stakepoold/$pod.cert "
  done
  kubectl delete configmap wallet-certs
  kubectl create configmap wallet-certs --from-literal=certs=$(echo $wallet_certs | sed -e "s/ /,/g")
  kubectl delete configmap stakepool-certs
  kubectl create configmap stakepool-certs --from-literal=certs=$(echo $stakepool_certs | sed -e "s/ /,/g")
}

init(){
  source ./variables.sh

  echo "Setting DCRStakepool"
  if [ ! -f dcrpoolstake.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout dcrpoolstake.key -out dcrpoolstake.crt -subj "/CN=dcrstakepool/O=dcrstakepool"
    kubectl delete secret nginxsecret
    kubectl create secret tls nginxsecret --key dcrpoolstake.key --cert dcrpoolstake.crt
  fi
  echo "Setting nginx configuration"
  kubectl delete configmap nginxconfigmap
  kubectl create configmap nginxconfigmap --from-file=nginx.conf
  echo "Setting stakepool-boot script"
  kubectl delete configmap dcrstakepool-bootscript
  kubectl create configmap dcrstakepool-bootscript --from-file=dcrstakepool-boot.sh
  echo "- Generating API Secret"
  kubectl delete secret api-secret
  kubectl create secret generic api-secret --from-literal=token=$(openssl rand -hex 32)
  echo "- Generating Cookie Secret"
  kubectl delete secret cookie-secret
  kubectl create secret generic cookie-secret --from-literal=token=$(openssl rand -hex 32)
  echo "- Setting pool email to $POOL_EMAIL"
  kubectl delete configmap pool-email
  kubectl create configmap pool-email --from-literal=poolemail=$POOL_EMAIL
  echo "- Setting pool email to $POOL_LINK"
  kubectl delete configmap pool-link
  kubectl create configmap pool-link --from-literal=poollink=$POOL_LINK
  echo "- Setting SMTP From to $SMTP_FROM"
  kubectl delete configmap smtp-from
  kubectl create configmap smtp-from --from-literal=smtpfrom=$SMTP_FROM
  echo "- Setting SMTP Host to $SMTP_HOST"
  kubectl delete configmap smtp-host
  kubectl create configmap smtp-host --from-literal=smtphost=$SMTP_HOST
  echo "- Setting SMTP Username to $SMTP_USERNAME"
  kubectl delete configmap smtp-username
  kubectl create configmap smtp-username --from-literal=smtpusername=$SMTP_USERNAME
  echo "- Setting SMTP Password to *******"
  kubectl delete configmap smtp-password
  kubectl create configmap smtp-password --from-literal=smtppassword=$SMTP_PASSWORD
  echo "- Setting Admin Ids to ADMIN_USER_IDS"
  kubectl delete configmap admin-ids
  kubectl create configmap admin-ids --from-literal=ids=$ADMIN_USER_IDS
  echo "- Setting Admin Ids to ADMIN_USER_IPS"
  kubectl delete configmap admin-ips
  kubectl create configmap admin-ips --from-literal=ips=$ADMIN_USER_IPS

  echo "Setting Mysql"
  echo "- Setting Mysql Pass to ******"
  kubectl delete secret mysql-pass
  kubectl create secret generic mysql-pass --from-literal=password=$MYSQL_PASS
  kubectl delete configmap mysql-bootstrap
  kubectl create configmap mysql-bootstrap --from-file=../mysql/bootstrap.sql
  kubectl delete configmap mysql-bootscript
  kubectl create configmap mysql-bootscript --from-file=../mysql/mysql-bootscript.sh

  echo "Setting Stakepoold"
  echo "- Setting Mysql Stakepool Pass to ******"
  kubectl delete secret stakepool-mysql-pass
  kubectl create secret generic stakepool-mysql-pass --from-literal=password=$STAKEPOOL_MYSQL_PASS
  kubectl delete configmap stakepoold-bootscript
  kubectl create configmap stakepoold-bootscript --from-file=../stakepool/stakepool-boot.sh
  kubectl delete secret rpc-user
  kubectl create secret generic rpc-user --from-literal=user=$RPC_USER
  kubectl delete secret rpc-pass
  kubectl create secret generic rpc-pass --from-literal=password=$RPC_PASS
  kubectl delete secret wallet-pass
  kubectl create secret generic wallet-pass --from-literal=privatewalletpass=$PRIVATE_WALLET_PASS
  kubectl delete secret coldwalletextpub
  kubectl create secret generic coldwalletextpub --from-literal=coldwalletextpub=$YOUR_COLD_WALLET_EXT_PUB
  kubectl delete configmap testnet-config
  kubectl create configmap testnet-config --from-literal=testnet=$TESTNET
}

mysql_deployment(){
  echo "$1 Mysql deployment"
  kubectl $1 -f ../mysql/mysql-deployment.yaml
}

stakepool_deployment(){
  echo "$1 Stakepool deployment"
  kubectl $1 -f ../stakepool/stakepool-deployment.yaml
}

dcrstakepool_deployment(){
  echo "$1 DCRStakepool deployment"
  kubectl $1 -f ../dcrstakepool/dcrstakepool-deployment.yaml
}

setup(){
    # To be implemented
    echo ""
}

for i in "$@"
do
case $i in
    -a|--apply)
      apply
    ;;
    -c|--update-config)
      dcrstakepool_update_config
    ;;
    -u|--upload-cert)
      dcrstakepool_upload_cert
    ;;
    -i|--init)
      init
    ;;
    -s|--setup)
      setup
    ;;
    -h|--help)
      show_help
    ;;
    *)
      show_help
    ;;
esac
done

exit 0

