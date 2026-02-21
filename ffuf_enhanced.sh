#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset)

# Function to print red text
print_red() {
    echo -e "${RED}$1${NC}"
}

# Function to print blue text
print_blue() {
    echo -e "${BLUE}$1${NC}"
}

# Function to print green text
print_green() {
    echo -e "${GREEN}$1${NC}"
}

# Parse ffuf output and identify outliers (z-score > 3)
# Usage: $0 -f <ffuf_output_file>

INPUT_FILE=""

while getopts ":f:" opt; do
    case ${opt} in
        f)
            INPUT_FILE="$OPTARG"
            ;;
        \?)
            print_red "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            print_red "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

# Find and print outliers (|z-score| > 3)
print_green "Outliers (|z-score| > 3):"
print_green "Mean: $mean | Std Dev: $std_dev"
echo ""

for i in "${!tokens[@]}"; do
    token="${tokens[$i]}"
    size="${sizes[$i]}"
    z_score=$(echo "scale=4; ($size - $mean) / $std_dev" | bc 2>/dev/null || echo "0")
    # Compare absolute z-score with 3
    is_outlier=$(echo "$z_score" | awk '{abs = ($1 < 0) ? -$1 : $1; print (abs > 3) ? 1 : 0}')
    if [[ "$is_outlier" -eq 1 ]]; then
        print_red "Token: $token | Size: $size | Z-score: $z_score"
    fi
done