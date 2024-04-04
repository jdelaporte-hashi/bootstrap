#!/bin/bash

set -e

if [ $# -eq 0 ] ;
then echo "Run again with at least one argument for cluster name."
fi

declare -i portpin=0
while [ $# -gt 0 ] ;
do
    clustername="$1"
    config_dir=$HOME/vault_cluster_configs/${clustername}
    api_port="82${portpin}0"
    cluster_port="82${portpin}1"


    ## Check if Vault already running on this port
    ## TODO: Increment port if Vault already running on this port
if ! lsof -i :${api_port} ;
then    
    # Set up config directory
    echo "$clustername ports are $api_port and $cluster_port"
    mkdir -p $config_dir
    mkdir -p $HOME/vault_data/vault_$clustername/data
    cp $HOME/vault_cluster_configs/template.hcl ${config_dir}/server.hcl
    sed -i '' "s/clustername/$clustername/g" ${config_dir}/server.hcl 
    sed -i '' "s/8200/$api_port/g" ${config_dir}/server.hcl
    sed -i '' "s/8201/$cluster_port/g" ${config_dir}/server.hcl

    #HOME=/Users/joani.delaporte
    echo "## Start up Cluster $clustername ##" | tee -a $HOME/secrets/vault-${clustername}.txt
    vault server -config $HOME/vault_cluster_configs/${clustername}&
    sleep 10

    echo "## Initialize $clustername cluster and send unseal keys to a file ##"
    export VAULT_ADDR="http://127.0.0.1:${api_port}"
    vault operator init -address=http://127.0.0.1:${api_port} -key-shares=1 -key-threshold=1 | tee -a $HOME/secrets/vault-${clustername}.txt

    echo "## Unseal key(s) and root token for $clustername cluster ##"
    head -n 3 $HOME/secrets/vault-${clustername}.txt
fi
    shift
    portpin+=1
done

echo '## Proof in the P(s)udding'
ps -ef | grep vault
cat $HOME/secrets/vault-*.txt
wait