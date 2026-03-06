#!/bin/bash

# Configuration
MAPPING_FILE="mapping.properties"

# Ensure mapping file exists
if [[ ! -f "$MAPPING_FILE" ]]; then
    echo "Error: Configuration file $MAPPING_FILE not found." >&2
    exit 1
fi

usage() {
    echo "Usage: $0 [-a|-d] <input_file>"
    echo "  -a: Anonymize (Original -> Placeholder)"
    echo "  -d: Deanonymize (Placeholder -> Original)"
    exit 1
}

# Core transformation logic
process() {
    local mode=$1
    local input=$2
    local output=""

    # State-over-interaction: Define output filename based on operation
    if [[ "$mode" == "anon" ]]; then
        output="${input%.*}.anon.txt"
    else
        output="${input%.*}.deanon.txt"
    fi

    # Copy input to output to preserve the original file
    cp "$input" "$output"

    # Iterate over properties file
    # Handle files without trailing newline by using [[ -n "$line" ]]
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Skip comments and empty lines
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        
        # Trim potential whitespace for cleaner mapping
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        if [[ "$mode" == "anon" ]]; then
            # Anonymize: Replace real data with tokens
            sed -i "s|${key}|${value}|g" "$output"
        else
            # Deanonymize: Replace tokens back with real data
            sed -i "s|${value}|${key}|g" "$output"
        fi
    done < "$MAPPING_FILE"

    echo "Finished. Result saved to: $output"
}

# Argument Parsing
while getopts "ad" opt; do
    case ${opt} in
        a) MODE="anon" ;;
        d) MODE="deanon" ;;
        *) usage ;;
    esac
done
shift $((OPTIND -1))

INPUT_FILE=$1

# Fail-Fast validation
if [[ -z "$MODE" || -z "$INPUT_FILE" ]]; then
    usage
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file $INPUT_FILE not found." >&2
    exit 1
fi

process "$MODE" "$INPUT_FILE"
