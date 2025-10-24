#!/bin/bash

# Paste this into your .bashrc or .zshrc file
# gives interactive gpu selection
cuda_select() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local NC='\033[0m' # No Color

    # Current status
    echo -e "${BLUE}Current CUDA_VISIBLE_DEVICES:${NC} ${CUDA_VISIBLE_DEVICES:-'(not set)'}"
    echo -ne "${YELLOW}Do you want to change it? [y/N]: ${NC}"
    read -r response

    # Default to 'N' if empty response
    response=${response:-N}

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted.${NC}"
        return 0
    fi

    # Check if nvidia-smi is available
    if ! command -v nvidia-smi &> /dev/null; then
        echo -e "${RED}Error: nvidia-smi not found. Make sure NVIDIA drivers are installed.${NC}"
        return 1
    fi

    # Get available GPU devices
    echo -e "\n${BLUE}Available GPU devices:${NC}"
    nvidia-smi --list-gpus | nl -v 0 -w 2 -s ': '

    # Also show a compact format with GPU info
    echo -e "\n${BLUE}Device details:${NC}"
    nvidia-smi --query-gpu=index,name,memory.total,utilization.gpu --format=csv,noheader,nounits | \
    awk -F', ' '{printf "%d: %s (%.0f MB, %d%% util)\n", $1, $2, $3, $4}'

    # Get total number of GPUs
    local gpu_count
    gpu_count=$(nvidia-smi --list-gpus | wc -l)

    if [ "$gpu_count" -eq 0 ]; then
        echo -e "${RED}No GPUs found.${NC}"
        return 1
    fi

    # Prompt for device selection
    echo -ne "\n${YELLOW}Enter device number(s) (0-$((gpu_count-1))), comma-separated, 'all' for all devices, or 'none' to clear: ${NC}"
    read -r device_input

    # Handle empty input
    if [ -z "$device_input" ]; then
        echo -e "${RED}No input provided. Aborted.${NC}"
        return 1
    fi

    # Handle 'none' option
    if [[ "$device_input" == "none" ]]; then
        unset CUDA_VISIBLE_DEVICES
        echo -e "${GREEN}CUDA_VISIBLE_DEVICES cleared (unset).${NC}"
        return 0
    fi

    # Handle 'all' option
    if [[ "$device_input" == "all" ]]; then
        device_input=$(seq -s, 0 $((gpu_count-1)))
    fi

    # Validate input format (numbers and commas only)
    if [[ ! "$device_input" =~ ^[0-9,]+$ ]]; then
        echo -e "${RED}Invalid input format. Use numbers and commas only (e.g., 0,1,2).${NC}"
        return 1
    fi

    # Convert comma-separated string to array and validate each device
    IFS=',' read -ra devices <<< "$device_input"
    for device in "${devices[@]}"; do
        if [ "$device" -ge "$gpu_count" ] || [ "$device" -lt 0 ]; then
            echo -e "${RED}Invalid device number: $device. Valid range: 0-$((gpu_count-1))${NC}"
            return 1
        fi
    done

    # Set the environment variable
    export CUDA_VISIBLE_DEVICES="$device_input"
    echo -e "${GREEN}CUDA_VISIBLE_DEVICES set to: $device_input${NC}"

    # Show confirmation with selected GPU names
    echo -e "\n${BLUE}Selected GPUs:${NC}"
    for device in "${devices[@]}"; do
        gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits -i "$device")
        echo -e "  Device $device: $gpu_name"
    done
}
