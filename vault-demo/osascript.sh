#!/bin/bash
set -e
if [ $# -eq 0 ] ;
then echo "Run again with at least one argument for cluster name, using Ocean, Pro , Orange, Grass, or Novel."
fi

for clustername in $@;
do
osascript << END
tell application "Terminal"
do script ""
set current settings of selected tab of window 1 to settings set "$clustername"
set custom title of tab 1 of front window to "Client $clustername"
do script "vault server -config $HOME/vault_cluster_configs/${clustername}&" in front window
end tell
END

done
