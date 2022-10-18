#!/usr/bin/env bash

DIR=$(realpath $(dirname "${BASH_SOURCE[0]}"))  # get the directory path

# shellcheck disable=SC2155
export SCRIPT_NAME=$(basename "${DIR}")
export LOG_PATH=/data/desk.log
export LOG_TO_CONSOLE=true

if [ -n ${DESK_TIME_ZONE+x} ]; then
    export TZ="${DESK_TIME_ZONE}"
fi

# shellcheck disable=SC1090
LOG_LEVEL="debug"
source "$DIR/utils.bash"

set +o errexit
python raiseDesk.py
RESULT=$?

if ((RESULT)); then
    errorIdle "Error: raiseDesk.py exited with code ${RESULT}"
fi
