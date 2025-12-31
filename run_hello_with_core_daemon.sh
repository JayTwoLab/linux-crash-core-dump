#!/bin/bash

# This script runs the hello program as a daemon,
# restarting it every time it exits.
#
# Before using this script, you must configure system-wide core dump settings
# using the setup_core_dump_systemwide.sh script.
# If not configured, coredump files will not be created.

set -euo pipefail
 
# Set working directory, executable path, and log file path
# WORKDIR="/home/jaytwo/workspace/coredump-workspace" # If you register this script as a service, be sure to set an absolute path.
WORKDIR="$(pwd)"
EXEC="${WORKDIR}/hello"
LOG="${WORKDIR}/hello_daemon.log"

cd "${WORKDIR}"

# Allow core dumps (applies to hello run by this script)
ulimit -c unlimited

# ASAN/UBSAN settings (if needed)
export ASAN_OPTIONS="abort_on_error=1:disable_coredump=0"
export UBSAN_OPTIONS="halt_on_error=1:abort_on_error=1"

# Log daemon start
echo "[$(date '+%F %T')] daemon start" >> "${LOG}"

# Limit log file size: if over 10MB, keep only the last 10,000 lines
MAX_LOG_SIZE=10485760 # 10MB
MAX_LOG_LINES=10000
if [ -f "${LOG}" ] && [ $(stat -c%s "${LOG}") -ge $MAX_LOG_SIZE ]; then
    tail -n $MAX_LOG_LINES "${LOG}" > "${LOG}.tmp" && mv "${LOG}.tmp" "${LOG}"
    echo "[$(date '+%F %T')] log trimmed to last $MAX_LOG_LINES lines" >> "${LOG}"
fi

while true; do

    # Log start of execution
    echo "[$(date '+%F %T')] starting hello" >> "${LOG}"

    # Run
    "${EXEC}"
    rc=$?

    # Log exit
    echo "[$(date '+%F %T')] hello exited rc=${rc}" >> "${LOG}"

    # Prevent too rapid restarts
    sleep 600 # seconds

    # NOTE: crash에 의한 소프트웨어 정지가 원인일 확률이 높으며, 
    # 그럴 경우 재시작하여도 동일한 문제가 반복될 수 있습니다. 
    # 이 점 유의하시기 바랍니다.
done


