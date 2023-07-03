#!/bin/bash
#
# C.A.R.P.: a Call Aware Radio Player
#
# see https://github.com/elektronenhirn/call_aware_radio_player
#

# Your favorite radio stations' streaming URL. Lookup at https://streamurl.link/
RADIO_STATION_URL="http://ors-sn06.ors-shoutcast.at/fm4-q2a"

# Output device for radio, lookup with 'pactl list short sinks'
RADIO_OUTPUT_DEVICE="alsa_output.pci-0000_01_00.1.hdmi-stereo"

# Input device for calls, lookup with 'pactl list short sources'
CALL_MICROPHONE_DEVICE="alsa_input.usb-0b0e_Jabra_Link_370_50C2ED094FE8-00.mono-fallback"

POLLING_INTERVAL_IN_SEC=1
RADIO_PID=
CALL_ONGOING=

COLOR='\033[1;32m'
NOCOLOR='\033[0m' # No Color

function log() {
    TIMESTAMP=$(date +"%Y-%m-%d %T")
    echo -e "${COLOR}${TIMESTAMP}  $*${NOCOLOR}"
}
function playRadio() {
    mpg123 -o pulse -a ${RADIO_OUTPUT_DEVICE} ${RADIO_STATION_URL} &
    RADIO_PID=$!
}

# returns 0 when call ongoing
function callOngoing() {
    REGEX="${CALL_MICROPHONE_DEVICE}.*RUNNING"
    pactl list short sources | grep -e "${REGEX}" > /dev/null
    echo $?
}

# $1 call state to handle (0 -> call ongoing)
function handleCallState() {
    if [[ "$1" == "0" ]]; then
        log "Ongoing call detected -> stopping radio"
        kill ${RADIO_PID} 2> /dev/null
    else
        log "No ongoing call detected -> playing radio"
        playRadio
    fi
}

log "Welcome to C.A.R.P. // press [CTRL+C] to stop.."

for (( ; ; ))
do
    CALL_ONGOING_NOW=$(callOngoing)
    if [[ "${CALL_ONGOING_NOW}" != "${CALL_ONGOING}" ]]; then
        handleCallState "${CALL_ONGOING_NOW}"
    fi
    CALL_ONGOING=${CALL_ONGOING_NOW}
    sleep ${POLLING_INTERVAL_IN_SEC}
#    log "call ongoing? ${CALL_ONGOING}"
done
