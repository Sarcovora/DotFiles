#!/bin/bash

# drop this in .bashrc / .zshrc
# conda_select: interactively switch conda environments with nicer UX
cas() {
    # ----- colors -----
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local NC='\033[0m' # reset

    # ----- conda available? -----
    if ! command -v conda >/dev/null 2>&1; then
        echo -e "${RED}Error: conda is not installed or not in PATH.${NC}"
        return 1
    fi

    # get the raw env list once
    local conda_list
    conda_list="$(conda env list 2>/dev/null)"
    if [ $? -ne 0 ] || [ -z "$conda_list" ]; then
        echo -e "${RED}Error: could not read environments from conda.${NC}"
        return 1
    fi

    # ----- detect current env name -----
    # prefer CONDA_DEFAULT_ENV, fall back to '*' marker in `conda env list`
    local current_env=""
    if [ -n "$CONDA_DEFAULT_ENV" ]; then
        current_env="$CONDA_DEFAULT_ENV"
    else
        current_env="$(echo "$conda_list" | awk '/\*/ {print $1; exit}')"
    fi

    # helper: shorten $HOME in a path for display
    _cas_shorten_path () {
        local p="$1"
        if [ -n "$HOME" ]; then
            printf '%s\n' "${p/#$HOME/~}"
        else
            printf '%s\n' "$p"
        fi
    }

    # arrays
    local -a envs paths pys
    local i=1

    # print header
    echo -e "${BLUE}Available conda environments:${NC}"

    # we'll read conda_list line by line and parse
    # formats we need to handle:
    #   "* base                  /home/.../anaconda3"
    #   "  rl_stuff              /home/.../anaconda3/envs/rl_stuff"
    #   "/abs/path/to/env"
    #
    # Strategy:
    #   1. strip leading "* " or leading spaces
    #   2. split remaining line into tokens
    #   3. if first token starts with "/", then name = basename(path), path = that token
    #      else name = first token, path = last token

    local line raw line_nostar first_token last_token env_name env_path py_version python_exe is_active short_path

    while IFS= read -r line; do
        # skip comments or blank lines
        case "$line" in
            \#*) continue ;;
            '') continue ;;
        esac

        # detect/strip leading star for active env
        is_active=""
        raw="$line"
        # trim leading spaces first
        raw="${raw#"${raw%%[![:space:]]*}"}"
        if [ "${raw#\* }" != "$raw" ]; then
            is_active="*"
            raw="${raw#\* }"
        fi

        # after stripping star + leading spaces, normalize internal spacing
        # we'll squeeze runs of space down to single space
        line_nostar="$(echo "$raw" | tr -s '[:space:]' ' ')"

        # grab first and last field
        first_token="$(echo "$line_nostar" | awk '{print $1}')"
        last_token="$(echo "$line_nostar"  | awk '{print $NF}')"

        if [ "${first_token#/}" != "$first_token" ]; then
            # first token starts with '/', so it's a path-only env
            env_path="$first_token"
            env_name="$(basename "$env_path")"
        else
            env_name="$first_token"
            env_path="$last_token"
        fi

        # compute python version
        py_version="N/A"
        for python_exe in \
            "$env_path/bin/python" \
            "$env_path/bin/python3" \
            "$env_path/python.exe" \
            "$env_path/Scripts/python.exe"
        do
            if [ -f "$python_exe" ]; then
                py_version="$("$python_exe" --version 2>&1 | awk '{print $2}')"
                break
            fi
        done

        envs[$i]="$env_name"
        paths[$i]="$env_path"
        pys[$i]="$py_version"

        short_path="$(_cas_shorten_path "$env_path")"

        # mark active env with [*] if it matches current_env OR we saw '*'
        if [ -n "$current_env" ] && [ "$env_name" = "$current_env" ]; then
            printf "%b%2d) [*] %-22s Py %-10s %s%b\n" \
                "$BLUE" "$i" "$env_name" "$py_version" "$short_path" "$NC"
        elif [ -n "$is_active" ]; then
            printf "%b%2d) [*] %-22s Py %-10s %s%b\n" \
                "$BLUE" "$i" "$env_name" "$py_version" "$short_path" "$NC"
        else
            printf "%2d) %-26s Py %-10s %s\n" \
                "$i" "$env_name" "$py_version" "$short_path"
        fi

        i=$((i+1))
    done <<< "$conda_list"

    local count=$((i-1))
    if [ "$count" -eq 0 ]; then
        echo -e "${RED}No conda environments found.${NC}"
        return 1
    fi

    echo ""
    echo -e "${YELLOW}Enter environment NUMBER to activate.${NC}"
    echo -ne "${YELLOW}(press ENTER to abort): ${NC}"
    read -r selection

    # abort path
    if [ -z "$selection" ]; then
        if [ -n "$current_env" ]; then
            echo -e "${GREEN}No change. Still in '${current_env}'.${NC}"
        else
            echo -e "${GREEN}No environment activated.${NC}"
        fi
        return 0
    fi

    # allow picking by name as well as number
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        local match_index=""
        local idx
        for idx in "${!envs[@]}"; do
            if [ "${envs[$idx]}" = "$selection" ]; then
                match_index="$idx"
                break
            fi
        done
        if [ -z "$match_index" ]; then
            for idx in "${!envs[@]}"; do
                case "${envs[$idx]}" in
                    *"$selection"*)
                        if [ -z "$match_index" ]; then
                            match_index="$idx"
                        else
                            echo -e "${RED}Ambiguous: multiple environments match '$selection'. Please choose by number.${NC}"
                            return 1
                        fi
                        ;;
                esac
            done
        fi
        if [ -z "$match_index" ]; then
            echo -e "${RED}No environment matches '$selection'.${NC}"
            return 1
        fi
        selection="$match_index"
    fi

    # now must be numeric
    if [ "$selection" -lt 1 ] || [ "$selection" -gt "$count" ]; then
        echo -e "${RED}Invalid selection: $selection. Valid range is 1-$count.${NC}"
        return 1
    fi

    local target_env="${envs[$selection]}"
    local target_path="${paths[$selection]}"
    local target_py="${pys[$selection]}"

    # already in that env?
    if [ -n "$current_env" ] && [ "$target_env" = "$current_env" ]; then
        echo -e "${YELLOW}You're already using '${target_env}'. No change.${NC}"
        return 0
    fi

    # activate
    echo -e "${BLUE}Activating: ${target_env}${NC}"
    conda activate "$target_path"

    echo -e "${GREEN}Now using '${target_env}' ($target_path) [Python ${target_py}]${NC}"
}

