#!/bin/bash

# This script runs the hello program to generate a core dump.
#
# Before using this script, you must configure system-wide core dump settings
# using the setup_core_dump_systemwide.sh script.
# If not configured, coredump files will not be created.

set -euo pipefail

# Set working directory and executable path
WORKDIR="/home/jaytwo/workspace/coredump-workspace"
EXEC="${WORKDIR}/hello"

cd "${WORKDIR}"

# Allow core dumps (applies only to current shell/process)
ulimit -c unlimited

# ASAN/UBSAN settings (if needed)
export ASAN_OPTIONS="abort_on_error=1:disable_coredump=0"
export UBSAN_OPTIONS="halt_on_error=1:abort_on_error=1"

# Run
"${EXEC}"

# If the program exits normally, it reaches here (usually not reached on crash)
echo "Program exited normally."

