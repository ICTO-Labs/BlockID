#!/bin/bash
network=${1:-local}
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Export environment variables
if [ ! -f "./scripts/set-env.sh" ]; then
    echo "Error: script set-env.sh not found."
    exit 1
fi
if [ "$network" = "ic" ]; then
    echo "${green}Preparing environment for MAINNET...${reset}"
    export VITE_ENV="production"
    ./scripts/set-env.sh 2>&1
else
    echo "${green}Preparing environment for DEVELOPMENT...${reset}"
    export VITE_ENV="development"
    ./scripts/set-env.sh 2>&1
fi