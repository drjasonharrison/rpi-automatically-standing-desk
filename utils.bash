#!/bin/bash
# common utility functions for balena container logging
function err_report() {
    echo "errexit on line $(caller)" >&2
}
trap err_report ERR

export SCRIPT_PID="$BASHPID"
export COMMIT_HASH="unknown"

function errorIdle() {
    while : ; do
        echolog "$1"
        sleep 600
    done
}

initLogFormat() {
    # set up LOG_FORMAT
    OS_NAME=$(uname -s)
    if [ "$OS_NAME" == "Darwin" ]; then
        LOG_FORMAT="[%Y-%m-%d %T]"
        debuglog "Running on Darwin, LOG_FORMAT = $LOG_FORMAT"
    else
        LOG_FORMAT="[%Y-%m-%d %T.%3N]"
        debuglog "Running on $OS_NAME, LOG_FORMAT = $LOG_FORMAT"
    fi
}

function initLogging() {
    initLogFormat

    if [ -z ${SERVICE_NAME+x} ]; then
        echolog "Util::initLogging: SERVICE_NAME is not defined"
        if [ -z ${BALENA_SERVICE_NAME+x} ]; then
            echolog "Util::initLogging: BALENA_SERVICE_NAME is not defined"
            export SERVICE_NAME=unknown
        else
            export SERVICE_NAME="${BALENA_SERVICE_NAME}"
        fi
    else
        echolog "Util::initLogging: SERVICE_NAME = ${SERVICE_NAME}"
    fi

    if [ -z ${LOG_PATH+x} ]; then
        echolog "LOG_PATH is not defined, searching for persistent volume"
        if [ -d /data ]; then
            echolog "found /data"
            export LOG_PATH="/data/log/${SERVICE_NAME}.log"
        else
            echolog "Error: unable to find /data"
        fi
        echolog "Warning: LOG_PATH not defined, using ${LOG_PATH}"
    else
        echolog "LOG_PATH defined as ${LOG_PATH}"
    fi

    LOG_FOLDER=$(dirname ${LOG_PATH})
    mkdir -p "$LOG_FOLDER"
    if [ ! -w "$LOG_FOLDER" ]; then
        errorIdle "Error: unable to write to ${LOG_FOLDER}"
    else
        echolog "Can write to ${LOG_FOLDER}"
    fi

    if [ -e ${LOG_PATH} ]; then
        if [ ! -w ${LOG_PATH} ]; then
            errorIdle "Error: unable to write to ${LOG_PATH}"
        fi
    else
        set +e
        touch ${LOG_PATH}
        exitStatus=$?
        set -e
        if [[ exitStatus -ne 0 ]]; then
            errorIdle "Error: unable to write to ${LOG_PATH}"
        fi
    fi

    # get the "/data/log/camera" part of /eio-data/log/camera.log
    export LOG_FOLDER_AND_LOG_FILE_PREFIX="${LOG_PATH%.*}"

    # now create "/eio-data/log/camera-runCommand.log"
    SCRIPT_LOG_LOCATION="${LOG_FOLDER_AND_LOG_FILE_PREFIX}-runCommand.log"
    if [ -e ${SCRIPT_LOG_LOCATION} ]; then
        if [ ! -w ${SCRIPT_LOG_LOCATION} ]; then
            errorIdle "Error: unable to write to ${SCRIPT_LOG_LOCATION}"
        fi
    else
        set +e
        touch ${SCRIPT_LOG_LOCATION}
        exitStatus=$?
        set -e
        if [[ exitStatus -ne 0 ]]; then
            errorIdle "Error: unable to write to ${SCRIPT_LOG_LOCATION}"
        fi
    fi

    echolog "SCRIPT_LOG_LOCATION = ${SCRIPT_LOG_LOCATION}"

    # make a copy of stdout and stderr file descriptors
    exec 3>&1 4>&2

    # set up logging to file and console
    if [ -z "${LOG_TO_CONSOLE+x}" ]; then
        echolog "LOG_TO_CONSOLE is not defined, sending output only to ${SCRIPT_LOG_LOCATION}"
        { exec 1>> "${SCRIPT_LOG_LOCATION}"; } 2>&1
    else
        echolog "LOG_TO_CONSOLE is defined, sending output to console and ${SCRIPT_LOG_LOCATION}"
        exec 1> >(tee -a -i "${SCRIPT_LOG_LOCATION}")
        exec 2>&1
    fi

    # start log with a blank line just in case the last writer didn't output a newline
    echolog ""
}

# https://unix.stackexchange.com/a/80995/249782
function stopLoggingToFile() {
    exec >&3 2>&4
}

function initVariables() {
    if [ -z ${DELAY_SLEEP_SECONDS+x} ]; then
        export DELAY_SLEEP_SECONDS=0
    fi

    if [ -z ${LOG_LEVEL+x} ]; then
        DELAY_SLEEP_SECONDS=0
    elif [ "$LOG_LEVEL" != "debug" ]; then
        DELAY_SLEEP_SECONDS=0
    fi

    if [ $DELAY_SLEEP_SECONDS -ne 0 ]; then
        echolog "Warning: all exits with delay will include a delay of $DELAY_SLEEP_SECONDS seconds"
    fi
}

function getCommitHash() {
    if [ -z ${BALENA_SUPERVISOR_ADDRESS+x} ]; then
        echolog "Util::getCommitHash: BALENA_SUPERVISOR_ADDRESS is not defined"
        return
    elif [ -z ${BALENA_SUPERVISOR_API_KEY+x} ]; then
        echolog "Util::getCommitHash: BALENA_SUPERVISOR_API_KEY is not defined"
        return
    fi

    set +e
    curlResult=$( (curl --connect-timeout 2 --max-time 2 --silent --fail --show-error \
                    "$BALENA_SUPERVISOR_ADDRESS/v2/applications/state?apikey=$BALENA_SUPERVISOR_API_KEY") 2>&1)
    exitStatus=$?
    set -e
    if [[ exitStatus -ne 0 ]]; then
        echolog "Error: unable to reach Balena supervisor, ${BALENA_SUPERVISOR_ADDRESS}"
        echolog "curl error $exitStatus, ${curlResult}"
        # 6 == Could not resolve host
        # 22 == page doesn't exist at server (404)
        # 22 == unauthorized (401)
        # 28 == Operation timed out after connect or max time -- docker or barnserv locked up
    else
        if ! [ -x "$(command -v jq)" ]; then
            echo 'Error: jq is not installed.' >&2
            return
        else
            echo -e "jq: \n$(jq --version)\n"
        fi
        set +e
        COMMIT_HASH=$(echo "${curlResult}" | jq '.[].commit')
        exitStatus=$?
        set -e
        if [[ exitStatus -ne 0 ]]; then
            echolog "Error: unable to parse Balena supervisor response: ${curlResult}"
        else
            echolog "Commit hash = $COMMIT_HASH"
        fi
    fi
}

function logContainerStartup() {
    startupLog "Starting Container ${SERVICE_NAME}"
    # echo "Starting Container ${SERVICE_NAME}" > /dev/kmsg

    startupLog "Uptime: $(uptime)"
    startupLog "Commit: $COMMIT_HASH"
    debuglog "OS_NAME is $OS_NAME"
}

# from https://serverfault.com/a/880885
# can be used an alternative to echo
# also can be piped into to handle multiple lines
# modified to use our date format
# WARNING: you have to use `echolog ""` to get a blank line
#
# note on the arguments to date:
# - the + starts the format
# - the format must be one argument, no spaces allowed, thus the "...+${LOG_FORMAT}"..."
# the entire echo argument is double quotes to preserve spaces
function echolog() {
    if [ -z ${LOG_FORMAT+x} ]; then
        echo "WARNING: LOG_FORMAT is not defined"
        initLogFormat
    fi

    # if there are no arguments then read from STDIN
    if [ $# -eq 0 ]; then
        cat - | while IFS= read -r message
        do
            echo "$(date "+${LOG_FORMAT}") [$SCRIPT_PID] $message"
        done
    else
        echo "$(date "+${LOG_FORMAT}") [$SCRIPT_PID] $*"
    fi
}

# debug level version of echolog()
function debuglog() {
    if [ -z ${LOG_LEVEL+x} ]; then
        return
    elif [ "$LOG_LEVEL" != "debug" ]; then
        return
    fi

    if [ -z ${LOG_FORMAT+x} ]; then
        echo "WARNING: LOG_FORMAT is not defined"
        initLogFormat
    fi

    if [ $# -eq 0 ]; then
        cat - | while IFS= read -r message
        do
            echo "$(date "+${LOG_FORMAT}") [$SCRIPT_PID] Debug: $message"
        done
    else
        echo "$(date "+${LOG_FORMAT}") [$SCRIPT_PID] Debug: $*"
    fi
}

# log to our regular logfile and a special startup log file
function startupLog() {
    logmsg="$(date "+${LOG_FORMAT}") [$SCRIPT_PID] $*"
    echo "$logmsg"
    echo "$logmsg" >> ${LOG_FOLDER_AND_LOG_FILE_PREFIX}-start.log
}

function errorExitWithDelay() {
    if [ $# -ne 0 ]; then
        echolog "Exiting: $*"
    fi
    if [ $DELAY_SLEEP_SECONDS -ne 0 ]; then
        echolog "Sleeping $DELAY_SLEEP_SECONDS seconds"
        sleep $DELAY_SLEEP_SECONDS
    fi
    idleIfDebugSet
    exit
}

# https://forums.balena.io/t/how-to-debug-a-container-which-is-in-a-crash-loop/5638
function idleIfDebugSet() {
    if [ -n "$DEBUG" ]; then
        echolog "idleIfDebugSet() called."
        while : ; do
            echolog "Idling..."
            sleep 600
        done
    fi
}

# useful for transfering files off of devices:
function transfer() {
    if [ $# -eq 0 ]; then
        echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi
    tmpfile=$( mktemp -t transferXXX )
    if tty -s; then
        basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"
    else
        curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> "$tmpfile"
    fi
    cat "$tmpfile"
    echo
    rm -f "$tmpfile"
}

debuglog "calling util.initLogging"
initLogging
debuglog "util.initLogging is done"

debuglog "calling util.initVariables"
initVariables
debuglog "util.initVariables is done"

debuglog "printing environment variables (excluding RESIN_*)"
printenv | grep -v "^RESIN_" | sort
debuglog "printed environment variables"

debuglog "calling util.getCommitHash"
getCommitHash
debuglog "util.getCommitHash is done"

debuglog "calling util.logContainerStartup"
logContainerStartup
debuglog "util.bash is done "
