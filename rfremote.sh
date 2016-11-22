#!/bin/bash

HOST=control

function log() {
  local message=$1
  echo "[$(date '+%Y-%m-%d %H:%M:%S:%3N')] ${message}"
}

function on_sniffed() {
  while read message; do
    local message=($message)
    local code=${message[1]}

    if [ "$code" != "pulse" ]; then
      local pub_topic="rfpi/remote"
      local payload=${code}
      log "MQTT PUB: ${pub_topic} ${payload}"
      mosquitto_pub --host ${HOST} --topic ${pub_topic} --message ${payload}
    fi
  done
}

./RFSniffer | on_sniffed
