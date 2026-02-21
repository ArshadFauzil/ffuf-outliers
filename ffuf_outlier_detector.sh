#!/bin/bash

# FFUF Outlier Detector - Shell wrapper for Java-based outlier identification
# Reads ffuf output, extracts sizes, calculates z-scores, prints outliers (|z-score| > 3) in red
# Usage: ./ffuf_outlier_detector.sh -f <ffuf_output_file>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAVA_SOURCE="${SCRIPT_DIR}/FfufOutlierDetector.java"
JAVA_CLASS="${SCRIPT_DIR}/FfufOutlierDetector.class"

# ANSI colors
RED='\033[0;31m'
NC='\033[0m'

print_red() {
    echo -e "${RED}$1${NC}"
}

# Check for Java
if ! command -v javac &> /dev/null || ! command -v java &> /dev/null; then
    print_red "Error: Java (javac and java) is required but not found."
    exit 1
fi

# Parse arguments
INPUT_FILE=""
while getopts ":f:" opt; do
    case ${opt} in
        f)
            INPUT_FILE="$OPTARG"
            ;;
        \?)
            print_red "Invalid option: -$OPTARG"
            echo "Usage: $0 -f <ffuf_output_file>"
            echo "   or: $0 <ffuf_output_file>"
            exit 1
            ;;
        :)
            print_red "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

# Allow positional argument if -f not used
if [[ -z "$INPUT_FILE" ]] && [[ -n "${1:-}" ]]; then
    INPUT_FILE="$1"
fi

if [[ -z "$INPUT_FILE" ]]; then
    print_red "Error: Input file is required."
    echo "Usage: $0 -f <ffuf_output_file>"
    echo "   or: $0 <ffuf_output_file>"
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    print_red "Error: File not found: $INPUT_FILE"
    exit 1
fi

# Compile Java if source is newer than class (or class doesn't exist)
if [[ ! -f "$JAVA_CLASS" ]] || [[ "$JAVA_SOURCE" -nt "$JAVA_CLASS" ]]; then
    if ! javac -source 8 -target 8 "$JAVA_SOURCE" 2>/dev/null; then
        javac "$JAVA_SOURCE" 2>/dev/null || {
            print_red "Error: Failed to compile FfufOutlierDetector.java"
            exit 1
        }
    fi
fi

# Run the Java outlier detector
cd "$SCRIPT_DIR"
java FfufOutlierDetector "$INPUT_FILE"
