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
        VAULT_ADDR="http://127.0.0.1:${api_port}"
        # Set up config directory
        echo "## Start up Cluster $clustername ##"
#        echo "#### $clustername ####" | tee -a $HOME/secrets/vault-${clustername}.txt 
#        echo "export VAULT_ADDR=${VAULT_ADDR}" | tee -a $HOME/secrets/vault-${clustername}.txt
#        mkdir -p $config_dir
        mkdir -p $HOME/vault_data/vault_$clustername/data
        cp $HOME/vault_cluster_configs/template.hcl ${config_dir}/server.hcl
        sed -i '' "s/clustername/$clustername/g" ${config_dir}/server.hcl 
        sed -i '' "s/8200/$api_port/g" ${config_dir}/server.hcl
        sed -i '' "s/8201/$cluster_port/g" ${config_dir}/server.hcl

        #HOME=/Users/joani.delaporte
        vault server -config $HOME/vault_cluster_configs/${clustername}&
        sleep 10

        echo "## Initialize $clustername cluster and send unseal keys to a file ##"
        export VAULT_ADDR=$VAULT_ADDR
#        vault operator init -address=${VAULT_ADDR} -key-shares=1 -key-threshold=1 | tee -a $HOME/secrets/vault-${clustername}.txt

        echo "## Unseal key(s) and root token for $clustername cluster ##"
        head -n 3 $HOME/secrets/vault-${clustername}.txt | tee vault-demo.txt
    fi
    shift
    portpin+=1
done

echo '## Proof in the P(s)udding ##'
ps -ef | grep vault
for f in $HOME/secrets/vault-*.txt; do head -n 6 $f; done | tee $HOME/secrets/vault-demo.txt
wait