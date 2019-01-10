#!/bin/bash

show_help(){
    echo "Help"
}

apply(){
  init
  dcrstakepool_update_config
  dcrstakepool_pod=$(kubectl get pods -l app=dcrstakepool-node -l tier=backend -n dcrstakepool -o jsonpath="{.items[0].metadata.name}")

  echo "Updating dcrstakepool deployment"
  kubectl apply -f dcrstakepool-deployment.yaml

  echo "Deleting dcrstakepool pod"
  kubectl delete pod -n dcrstakepool $dcrstakepool_pod

  sleep 30
  dcrstakepool_upload_cert

  echo "Done"
}

dcrstakepool_upload_cert(){
  echo "Processing Certs ..."
  dcrstakepool_pod=$(kubectl get pods -l app=dcrstakepool-node -l tier=backend -n dcrstakepool -o jsonpath="{.items[0].metadata.name}")

  for pod in $(kubectl get pods -l app=stakepoold-node -n dcrstakepool -o jsonpath="{.items[*].metadata.name}")
  do
    echo $pod
    echo "Getting Wallet Certs"
    kubectl cp -n dcrstakepool $pod:/home/decred/.dcrwallet/rpc.cert ./certs/dcrwallet/$pod.cert || { echo 'A problem occured, please retry.' ; exit 1; }
    kubectl cp -n dcrstakepool ./certs/dcrwallet/$pod.cert $dcrstakepool_pod:/home/decred/certs/dcrwallet/$pod.cert || { echo 'A problem occured, please retry.' ; exit 1; }
    echo "Getting Pool Stake Certs"
    kubectl cp -n dcrstakepool $pod:/home/decred/.stakepoold/rpc.cert ./certs/stakepoold/$pod.cert || { echo 'A problem occured, please retry.' ; exit 1; }
    kubectl cp -n dcrstakepool ./certs/stakepoold/$pod.cert $dcrstakepool_pod:/home/decred/certs/stakepoold/$pod.cert || { echo 'A problem occured, please retry.' ; exit 1; }
    wallet_certs=$wallet_certs"/home/decred/certs/dcrwallet/$pod.cert "
    stakepool_certs=$stakepool_certs"/home/decred/certs/stakepoold/$pod.cert "
  done
  kubectl delete configmap wallet-certs -n dcrstakepool
  kubectl create configmap wallet-certs -n dcrstakepool --from-literal=certs=$(echo $wallet_certs | sed -e "s/ /,/g")
  kubectl delete configmap stakepool-certs -n dcrstakepool
  kubectl create configmap stakepool-certs -n dcrstakepool --from-literal=certs=$(echo $stakepool_certs | sed -e "s/ /,/g")

  echo "Updating DCRStakepool deployment"
  dcrstakepool_deployment "apply"

  echo "Reloading nginx pod"
  kubectl exec -ti -n dcrstakepool $(kubectl get pods -l app=dcrstakepool-node -l tier=frontend -n dcrstakepool -o jsonpath="{.items[0].metadata.name}") -- sh -c "nginx -s stop ; nginx ; nginx -s reopen"

}

dcrstakepool_update_config(){
  source ./variables.sh
  echo "Processing Wallets Hosts ..."
  stakepoold_node_ips=$(kubectl get pods -l app=stakepoold-node -n dcrstakepool -o jsonpath="{.items[*].status.podIP}" | sed -e "s/ /,/g" )
  kubectl delete configmap wallet-hosts -n dcrstakepool
  kubectl create configmap wallet-hosts -n dcrstakepool --from-literal=hosts=$stakepoold_node_ips

  echo "Getting Wallet Extended Public Key"
  votingwalletextpub=$(kubectl exec -ti -n dcrstakepool $(kubectl get pods -l app=stakepoold-node -n dcrstakepool -o jsonpath="{.items[0].metadata.name}") -c stakepoold -- /bin/bash -c '/home/decred/go/bin/dcrctl --wallet $TESTNET -u $DCR_RPC_USER -P $DCR_RPC_PASS --rpcserver=$(hostname --ip-address) getmasterpubkey default')

  kubectl delete secret votingwalletextpub -n dcrstakepool
  if [ -z $votingwalletextpub ]
  then
    echo "Please re-run Voting Wallet Extended Public isn't set yet"
  else
    kubectl create secret generic votingwalletextpub -n dcrstakepool --from-literal=votingextpub=$(echo -e $votingwalletextpub)
  fi

  echo "Setting Cold Wallet Extended Public Key"
  kubectl delete secret coldwalletextpub -n dcrstakepool
  kubectl create secret generic coldwalletextpub -n dcrstakepool --from-literal=coldwalletextpub=$YOUR_COLD_WALLET_EXT_PUB

  # Generating wallet-certs and stakepool-certs names
  for pod in $(kubectl get pods -l app=stakepoold-node -n dcrstakepool -o jsonpath="{.items[*].metadata.name}")
  do
    echo $pod
    wallet_certs=$wallet_certs"/home/decred/certs/dcrwallet/$pod.cert "
    stakepool_certs=$stakepool_certs"/home/decred/certs/stakepoold/$pod.cert "
  done
  kubectl delete configmap wallet-certs -n dcrstakepool
  kubectl create configmap wallet-certs -n dcrstakepool --from-literal=certs=$(echo $wallet_certs | sed -e "s/ /,/g")
  kubectl delete configmap stakepool-certs -n dcrstakepool
  kubectl create configmap stakepool-certs -n dcrstakepool --from-literal=certs=$(echo $stakepool_certs | sed -e "s/ /,/g")
}

init(){
  source ./variables.sh

  kubectl create namespace dcrstakepool || { echo 'Namespace already exist' ; }

  echo "Setting DCRStakepool"
  if [ ! -f dcrpoolstake.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout dcrpoolstake.key -out dcrpoolstake.crt -subj "/CN=dcrstakepool/O=dcrstakepool"
    kubectl delete secret nginxsecret -n dcrstakepool
    kubectl create secret tls nginxsecret -n dcrstakepool --key dcrpoolstake.key --cert dcrpoolstake.crt
  fi

  kubectl get secret nginxsecret -n dcrstakepool || { echo 'Nginx Certificates not set' ; exit 1; }

  echo "Setting nginx configuration"
  kubectl delete configmap -n dcrstakepool dcrstakepool-nginx-config
  kubectl create configmap -n dcrstakepool dcrstakepool-nginx-config --from-file=nginx.conf
  echo "Setting stakepool-boot script"
  kubectl delete configmap -n dcrstakepool dcrstakepool-bootscript
  kubectl create configmap -n dcrstakepool dcrstakepool-bootscript --from-file=dcrstakepool-boot.sh
  echo "- Generating API Secret"
  kubectl delete secret api-secret -n dcrstakepool
  kubectl create secret generic api-secret -n dcrstakepool --from-literal=token=$(openssl rand -hex 32)
  echo "- Generating Cookie Secret"
  kubectl delete secret cookie-secret -n dcrstakepool
  kubectl create secret generic cookie-secret -n dcrstakepool --from-literal=token=$(openssl rand -hex 32)
  echo "- Setting pool email to $POOL_EMAIL"
  kubectl delete configmap pool-email -n dcrstakepool
  kubectl create configmap pool-email -n dcrstakepool --from-literal=poolemail=$POOL_EMAIL
  echo "- Setting pool email to $POOL_LINK"
  kubectl delete configmap pool-link -n dcrstakepool
  kubectl create configmap pool-link -n dcrstakepool --from-literal=poollink=$POOL_LINK
  echo "- Setting SMTP From to $SMTP_FROM"
  kubectl delete configmap smtp-from -n dcrstakepool
  kubectl create configmap smtp-from -n dcrstakepool --from-literal=smtpfrom=$SMTP_FROM
  echo "- Setting SMTP Host to $SMTP_HOST"
  kubectl delete configmap smtp-host -n dcrstakepool
  kubectl create configmap smtp-host -n dcrstakepool --from-literal=smtphost=$SMTP_HOST
  echo "- Setting SMTP Username to $SMTP_USERNAME"
  kubectl delete configmap smtp-username -n dcrstakepool
  kubectl create configmap smtp-username -n dcrstakepool --from-literal=smtpusername=$SMTP_USERNAME
  echo "- Setting SMTP Password to *******"
  kubectl delete configmap smtp-password -n dcrstakepool
  kubectl create configmap smtp-password -n dcrstakepool --from-literal=smtppassword=$SMTP_PASSWORD
  echo "- Setting Admin Ids to ADMIN_USER_IDS"
  kubectl delete configmap admin-ids -n dcrstakepool
  kubectl create configmap admin-ids -n dcrstakepool --from-literal=ids=$ADMIN_USER_IDS
  echo "- Setting Admin Ids to ADMIN_USER_IPS"
  kubectl delete configmap admin-ips -n dcrstakepool
  kubectl create configmap admin-ips -n dcrstakepool --from-literal=ips=$ADMIN_USER_IPS

  echo "Setting Mysql"
  echo "- Setting Mysql Pass to ******"
  kubectl delete secret mysql-pass -n dcrstakepool
  kubectl create secret generic mysql-pass -n dcrstakepool --from-literal=password=$MYSQL_PASS
  kubectl delete configmap mysql-bootstrap -n dcrstakepool
  kubectl create configmap mysql-bootstrap -n dcrstakepool --from-file=./mysql/bootstrap.sql
  kubectl delete configmap mysql-bootscript -n dcrstakepool
  kubectl create configmap mysql-bootscript -n dcrstakepool --from-file=./mysql/mysql-bootscript.sh

  echo "Setting Stakepoold"
  echo "- Setting Mysql Stakepool Pass to ******"
  kubectl delete secret stakepool-mysql-pass -n dcrstakepool
  kubectl create secret generic stakepool-mysql-pass -n dcrstakepool --from-literal=password=$STAKEPOOL_MYSQL_PASS
  kubectl delete configmap stakepoold-bootscript -n dcrstakepool
  kubectl create configmap stakepoold-bootscript -n dcrstakepool --from-file=./stakepool/stakepool-boot.sh
  kubectl delete secret rpc-user -n dcrstakepool
  kubectl create secret generic rpc-user -n dcrstakepool --from-literal=user=$RPC_USER
  kubectl delete secret rpc-pass -n dcrstakepool
  kubectl create secret generic rpc-pass -n dcrstakepool --from-literal=password=$RPC_PASS
  kubectl delete secret wallet-pass -n dcrstakepool
  kubectl create secret generic wallet-pass -n dcrstakepool --from-literal=privatewalletpass=$PRIVATE_WALLET_PASS
  kubectl delete secret coldwalletextpub -n dcrstakepool
  kubectl create secret generic coldwalletextpub -n dcrstakepool --from-literal=coldwalletextpub=$YOUR_COLD_WALLET_EXT_PUB
  kubectl delete configmap testnet-config -n dcrstakepool
  kubectl create configmap testnet-config -n dcrstakepool --from-literal=testnet=$TESTNET
}

mysql_deployment(){
  echo "$1 Mysql deployment"
  kubectl $1 -f ./mysql/mysql-deployment.yaml
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
