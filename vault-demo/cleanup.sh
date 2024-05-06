#!/bin/bash

echo "This script deletes all vault data in $HOME/vault_data."
read -p "Ctrl+c to Cancel or Enter to continue"

echo "Deleting data now ..."

rm -r $HOME/vault_data/*/data/*
rm -r $HOME/secrets/vault-*.txt
