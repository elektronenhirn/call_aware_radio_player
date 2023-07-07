#!/bin/bash
#
# carp:  Call Aware Radio Player
#
# see https://github.com/elektronenhirn/call_aware_radio_player
#

RADIO_STATION_URL=
POLLING_INTERVAL_IN_SEC=1
RADIO_PID=
CALL_ONGOING=

GREEN='\033[1;32m'
RED='\033[1;31m'
NOCOLOR='\033[0m'

function log() {
    TIMESTAMP=$(date +"%Y-%m-%d %T")
    echo -e "${GREEN}${TIMESTAMP}  $*${NOCOLOR}"
}

function error() {
    echo -e "${RED}$*${NOCOLOR}"
}

function printHelp() {
    echo "Call Aware Radio Player"
    echo ""
    echo "USAGE:"
    echo " $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "-u, --url <radio_stream>     Radio stream to play (see https://streamurl.link/)"
    echo "-o, --output <pa_device>     Pulse Audio device to play on (see 'pactl list short sinks')"
    echo ""
}

function playRadio() {
    OUTPUT_DEVICE_SEGMENT=
    if [ "${OUTPUT_DEVICE}" != "" ]; then
        OUTPUT_DEVICE_SEGMENT="-a ${OUTPUT_DEVICE}"
    fi
    mpg123 -o pulse ${OUTPUT_DEVICE_SEGMENT} ${STREAMING_URL} &
    RADIO_PID=$!
}

# returns 0 when call ongoing
function callOngoing() {
    REGEX=".*RUNNING"
    pactl list short sources | grep -e "${REGEX}" > /dev/null
    echo $?
}

function selectRadioStation() {
    RADIO_STATION_NAME[1]="FM4 from Vienna/Austria"
    RADIO_STATION_URL[1]="http://ors-sn06.ors-shoutcast.at/fm4-q2a"

    RADIO_STATION_NAME[2]="KEXP from Seattle/USA"
    RADIO_STATION_URL[2]="http://kexp-mp3-128.streamguys1.com/kexp128.mp3"

    RADIO_STATION_NAME[3]="NBC from Bolzano/Italy"
    RADIO_STATION_URL[3]="http://s6.mediastreaming.it:7020/;"

    PS3='Select a radio station: '

    options=("${RADIO_STATION_NAME[1]}", "${RADIO_STATION_NAME[2]}", "${RADIO_STATION_NAME[3]}")
    select opt in "${options[@]}"
    do
        case $REPLY in
            1)
                echo "→ Selected ${RADIO_STATION_NAME[1]}"
                STREAMING_URL="${RADIO_STATION_URL[1]}"
                break
                ;;
            2)
                echo "→ Selected ${RADIO_STATION_NAME[2]}"
                STREAMING_URL="${RADIO_STATION_URL[2]}"
                break
                ;;
            3)
                echo "→ Selected ${RADIO_STATION_NAME[3]}"
                STREAMING_URL="${RADIO_STATION_URL[3]}"
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
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


# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--url)
      STREAMING_URL="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--outputdevice)
      OUTPUT_DEVICE="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      printHelp
      shift # past argument
      exit 0
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ "${STREAMING_URL}" = "" ]; then
    echo "No streaming URL given on the command line, pick a radio station from the list:"
    selectRadioStation
fi

if [ "${OUTPUT_DEVICE}" = "" ]; then
    echo "No output device given on the command line"
    echo "→ using system's default"
fi

echo "Press [CTRL+C] to stop playing or monitoring call state"

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
