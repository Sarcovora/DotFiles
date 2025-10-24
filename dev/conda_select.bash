#!/bin/bash

# Paste this into your .bashrc or .zshrc file
# gives interactive conda env selection
cas () {
    if ! command -v conda &> /dev/null; then
        echo "Error: conda is not installed or not in PATH"
        return 1
    fi

    echo "Available conda environments:"
    echo "=============================="

    local -a envs paths
    local i=1
    local line env_name env_path py_version python_exe

    while IFS= read -r line; do
        [[ "$line" =~ ^#.* ]] && continue
        [[ -z "$line" ]] && continue

        if [[ "$line" =~ ^[[:space:]]+(/.*) ]]; then
            env_path="${BASH_REMATCH[1]}"
            env_name=$(basename "$env_path")
        else
            env_name=$(echo "$line" | awk '{print $1}')
            env_path=$(echo "$line" | awk '{print $NF}')
        fi

        py_version="N/A"
        for python_exe in "$env_path/bin/python" "$env_path/bin/python3" "$env_path/python.exe" "$env_path/Scripts/python.exe"; do
            if [ -f "$python_exe" ]; then
                py_version=$("$python_exe" --version 2>&1 | awk '{print $2}')
                break
            fi
        done

        envs[$i]="$env_name"
        paths[$i]="$env_path"

        printf "%2d) %-30s (Python %s)\n" $i "$env_name" "$py_version"
        ((i++))
    done < <(conda env list)

    if [ ${#envs[@]} -eq 0 ]; then
        echo "No conda environments found"
        return 1
    fi

    echo ""
    echo -n "Select environment number (or press Enter to cancel): "
    read selection

    if [ -z "$selection" ]; then
        echo "Cancelled"
        return 0
    fi

    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $((i-1)) ]; then
        echo "Invalid selection"
        return 1
    fi

    echo "Activating: ${envs[$selection]}"
    conda activate "${paths[$selection]}"
}
