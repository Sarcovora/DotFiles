#!/bin/bash

# Author: Evan Kuo
# Description: Used to commit and push changes to the git repository
# Add the following to your rc file: alias savelife='[vault path]/.commit_push.bash'

cd "$(dirname "$0")"

# ANSI escape code for green and yellow colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
# Reset color to default
NC='\033[0m'

current_date_time=$(date +"%m/%d/%Y %H:%M:%S")

# Check for any changes in the working directory or staged files
if [[ -z $(git status --porcelain) ]]; then
    echo -e "${GREEN}󰦘 No changes to push.${NC}"
    exit 0
fi

echo -e "${YELLOW}󰦘 Pushing changes...${NC}\n"

git diff --stat
git add .
git commit -m "lifevault $current_date_time" --quiet
git push --quiet

echo -e "\n${GREEN}󰄴 Changes pushed${NC}"
