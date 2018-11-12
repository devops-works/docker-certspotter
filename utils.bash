#!/bin/bash

function log() {
  echo "$(date --iso-8601=second) $*"
}

function info() {
  log "[INFO]" $*
}

function warning() {
  log "[WARNING]" $*
}

function error() {
  log "[ERROR]" $*
}

function debug() {
  if [ -n "${CS_DEBUG}" ]; then
    log "[DEBUG]" $*
  fi
}


