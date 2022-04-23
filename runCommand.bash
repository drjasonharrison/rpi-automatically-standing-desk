#!/bin/bash

set -euo pipefail
pigpiod
export PIGPIO_ADDR=soft
export PIGPIO_PORT=8888
exit 0

python raiseDesk.py
