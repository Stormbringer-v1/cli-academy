#!/usr/bin/env bash

# Extraction helper for <<TASK>>...<<END>> blocks
extract_task_content() {
    local FILE=$1
    # Simple awk-based extraction
    awk '/<<TASK>>/{flag=1;next}/<<END>>/{flag=0}flag' "$FILE"
}

# Validator functions

# content_check
# MUST_CONTAIN (array or string)
# MUST_NOT_CONTAIN (array or string)
validate_content() {
    local FILE=$1
    local TASK_CONTENT
    TASK_CONTENT=$(extract_task_content "$FILE")

    # Handle MUST_CONTAIN
    if [[ ${#MUST_CONTAIN[@]} -gt 0 ]]; then
        for string in "${MUST_CONTAIN[@]}"; do
            if ! grep -q -- "$string" <<< "$TASK_CONTENT"; then
                # echo "DEBUG: Missing $string"
                return 1
            fi
        done
    fi

    # Handle MUST_NOT_CONTAIN
    if [[ ${#MUST_NOT_CONTAIN[@]} -gt 0 ]]; then
        for string in "${MUST_NOT_CONTAIN[@]}"; do
            if grep -q -- "$string" <<< "$TASK_CONTENT"; then
                # echo "DEBUG: Found forbidden $string"
                return 1
            fi
        done
    fi

    return 0
}

# file_exists
# EXPECTED_FILE (string)
# EXPECTED_CONTENT (string, optional)
validate_file_exists() {
    local FILE_PATH=$1
    local CONTENT=${2:-""}

    if [[ ! -f "$FILE_PATH" ]]; then
        return 1
    fi

    if [[ -n "$CONTENT" ]]; then
        if ! grep -q -- "$CONTENT" "$FILE_PATH"; then
            return 1
        fi
    fi

    return 0
}

# diff_check
# EXPECTED_FILE (path to file with expected content)
# ACTUAL_FILE (path to actual file)
validate_diff() {
    local EXPECTED=$1
    local ACTUAL=$2
    if cmp -s "$EXPECTED" "$ACTUAL"; then
        return 0
    else
        return 1
    fi
}

# command_check
# COMMAND (string)
validate_command() {
    local CMD=$1
    if eval "$CMD" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# script
# SCRIPT_PATH (path to validation script)
# FILE_PATH (path to file to validate, optional)
validate_script() {
    local SCRIPT=$1
    local FILE=${2:-""}
    if [[ -f "$SCRIPT" ]]; then
        bash "$SCRIPT" "$FILE" </dev/null
        return $?
    else
        return 1
    fi
}
