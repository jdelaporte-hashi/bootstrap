#!/bin/bash

echo "This script kills all running vault processes and deletes all vault data in $HOME/vault_data."
read -p "Ctrl+c to Cancel or Enter to continue"

echo "Processes running ..."
ps -ef | grep vault

echo "Killing processes now ..."
pkill vault

echo "Deleting data in $HOME/vault_data/*/data/* and $HOME/secrets/vault-*.txt now ..."

rm -r $HOME/vault_data/*/data/*
rm -r $HOME/secrets/vault-*.txt