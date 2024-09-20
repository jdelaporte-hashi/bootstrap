#!/bin/bash

set -e

if [ $# -eq 0 ] ;
then echo "Run again with at least one argument for cluster name, using Ocean, Pro , Orange, Grass, or Novel."
fi

declare -i portpin=0

for clustername in $@;
do
    config_dir=$HOME/vault_cluster_configs/${clustername}
    api_port="82${portpin}0"
    cluster_port="82${portpin}1"


    ## Check if Vault already running on this port
    ## TODO: Increment port if Vault already running on this port
    if ! lsof -i ":${api_port}";
    then    
        VAULT_ADDR="http://127.0.0.1:${api_port}"
        # Set up config directory
        echo "## Start up Cluster $clustername ##"
        echo "#### $clustername ####" | tee -a $HOME/secrets/vault-${clustername}.txt 
        echo "export VAULT_ADDR=${VAULT_ADDR}" | tee -a $HOME/secrets/vault-${clustername}.txt
        mkdir -p $config_dir
        mkdir -p $HOME/vault_data/vault_$clustername/data
        cp $HOME/vault_cluster_configs/template.hcl ${config_dir}/server.hcl
        sed -i '' "s/clustername/$clustername/g" ${config_dir}/server.hcl 
        sed -i '' "s/8200/$api_port/g" ${config_dir}/server.hcl
        sed -i '' "s/8201/$cluster_port/g" ${config_dir}/server.hcl

echo "osascript should open a terminal tab for vault server"
osascript << END
tell application "Terminal"
do script ""
set current settings of selected tab of window 1 to settings set "$clustername"
set custom title of tab 1 of front window to "Client $clustername"
do script "vault server -config $HOME/vault_cluster_configs/${clustername}&" in front window
end tell
END
echo "Finished osascript for server ${clustername}"
	## Wait for server to start up
        sleep 10

        echo "## Initialize $clustername cluster and send unseal keys to a file ##"
        export VAULT_ADDR=$VAULT_ADDR
        vault operator init -address=${VAULT_ADDR} -key-shares=1 -key-threshold=1 | tee -a $HOME/secrets/vault-${clustername}.txt

        echo "## Unseal key(s) and root token for $clustername cluster ##"
        head -n 3 $HOME/secrets/vault-${clustername}.txt | tee vault-demo.txt
        
echo "Start a client session in a new Terminal tab"

osascript << SIGH
tell application "Terminal"
do script ""
set current settings of selected tab of window 1 to settings set "$clustername"
set custom title of tab 1 of front window to "Client $clustername"
do script "echo 'client session for ${clustername}&'" in front window
end tell
SIGH

#tell application "Terminal"
#do script ""
#set current settings of selected tab of window 1 to settings set "$clustername"
#set custom title of tab 1 of front window to "Client $clustername"
#do script 'echo "Client session for ${clustername}&"' in front window
#end tell
echo "Done with osascript for client ${clustername}"

    fi
    shift
    portpin+=1
done

echo '## Proof in the P(s)udding ##'
ps -ef | grep vault
for f in $HOME/secrets/vault-*.txt
    do 
    head -n 6 $f |  tee $HOME/secrets/vault-demo.txt
    done