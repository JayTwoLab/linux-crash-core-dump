#!/bin/bash

# This script runs gdb to analyze the specified core dump file.

set -euo pipefail

# Set working directory and executable path
WORKDIR="/home/jaytwo/workspace/coredump-workspace"
EXEC="${WORKDIR}/hello"
 
# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <core_dump_file>"
    echo "Example: $0 core.hello.18078.1766666152"
    exit 1
fi
# To get the time info from core.<program>.<pid>.<timestamp>, use date -d "@timestamp" to convert.
# Example: date -d "@1766666152" '+%Y-%m-%d %H:%M:%S %Z'
# Or use the ./list_core_with_time.sh script.

CORE_FILE="$1"

# Change directory
cd "${WORKDIR}"

# Check if core file exists
if [ ! -f "${CORE_FILE}" ]; then
                        echo "Error: core file does not exist: ${CORE_FILE}"
    exit 1
fi

# Check if executable exists
if [ ! -x "${EXEC}" ]; then
    echo "Error: executable does not exist or is not executable: ${EXEC}"
    exit 1
fi

echo "Run gdb:"
echo "  exe : ${EXEC}"
echo "  core: ${CORE_FILE}"
echo

# Run gdb
gdb "${EXEC}" "${CORE_FILE}"

