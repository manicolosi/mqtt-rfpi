#!/bin/bash

HOST=control

function log() {
  local message=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S:%3N')] ${message}"
}

function send_code() {
  local outlet=$1
  local state=$2

  if [ "$state" = "OFF" ]; then
    local code=$((outlet + 9))
  elif [ "$state" = "ON" ]; then
    local code=$outlet
  else
    log "Unknown state: ${state}"
    return
  fi

  log "Sending ${code}"

  #./codesend $code
  sleep 0.25
}

function on_message() {
  while read message; do
    log "MQTT SUB: ${message}"

    local message=($message)
    local topic=${message[0]}
    local payload=${message[1]}

    local topic_parts=(${topic//\// })
    local outlet=${topic_parts[2]}

    send_code "${outlet}" "${payload}"

    if [ $? -eq 0 ]; then
      local pub_topic="rfpi/outlet/${outlet}/state" 
      log "MQTT PUB: ${pub_topic} ${payload}"
      mosquitto_pub --host ${HOST} --topic ${pub_topic} --message ${payload} --retain
    fi
  done
}

mosquitto_sub -v -h ${HOST} -t "rfpi/outlet/+/set" | on_message
