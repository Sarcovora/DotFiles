#!/bin/bash

# Author: Evan Kuo
# Description: Used to check status of the git repo
# Add the following to your rc file: alias lgst='[vault path]/.gstatus.bash'

cd "$(dirname "$0")"

git status
