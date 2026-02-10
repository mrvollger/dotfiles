#!/bin/bash
set -euo pipefail 

NODE=$(ssh hyak 'squeue \
    --user mvollger \
    --states RUNNING \
    --name tmp_node_script.sh \
    --Format NodeList \
    --noheader ')

echo $NODE

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' -E "s/Hostname.*/Hostname $NODE/" ~/.ssh/klone-node-config
else
    sed -i -E "s/Hostname.*/Hostname $NODE/" ~/.ssh/klone-node-config
fi

