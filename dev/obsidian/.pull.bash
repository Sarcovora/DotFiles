#!/bin/bash

# Author: Evan Kuo
# Description: Used to pull changes to the git repository
# Add the following to your rc file: alias lifepull='[vault path]/.pull.bash'

cd "$(dirname "$0")"

# ANSI escape code for green and yellow colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
# Reset color to default
NC='\033[0m'

current_date_time=$(date +"%m/%d/%Y %H:%M:%S")

git pull

echo -e "\n${GREEN}󰄴 Changes pulled.${NC}"
