#!/bin/bash
DIR=$(dirname "${BASH_SOURCE[0]}")  # get the directory name
DIR=$(realpath "${DIR}")    # resolve its full path if need be
# shellcheck disable=SC2155
export SCRIPT_NAME=$(basename "${DIR}")
export LOG_PATH=/data
export LOG_TO_CONSOLE=true
# shellcheck disable=SC1090
source "$DIR/utils.bash"

set -euo pipefail
pigpiod
export PIGPIO_ADDR=soft
export PIGPIO_PORT=8888

while true; do
    sleep 10
    
exit 0

python raiseDesk.py
