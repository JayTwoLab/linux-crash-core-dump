#!/bin/bash

set -euo pipefail

# This script must be run with sudo.
# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo (root privileges)."
    echo "Example: sudo $0"
    exit 1
fi

# Create core files in the execution directory: core.<exe>.<pid>.<time>
CORE_PATTERN="core.%e.%p.%t"
# Example to read time info: date -d @1735123456 '+%Y-%m-%d %H:%M:%S %Z'

# Set global configuration to create files instead of using systemd-coredump pipe
sysctl -w kernel.core_pattern="${CORE_PATTERN}"

# (Recommended) Adding pid to core dump filename reduces risk of overwriting existing dumps
# Core file permissions/path depend on process privileges and execution directory permissions.

echo "OK: kernel.core_pattern=${CORE_PATTERN}"
echo "NOTE: This setting is system-wide and may persist after reboot (depends on distribution settings)."

