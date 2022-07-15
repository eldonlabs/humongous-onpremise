#!/usr/bin/env bash

# See https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail

# MAYBE_SUDO will prepend "sudo" to command on linux distributions.
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export MAYBE_SUDO="sudo"
else
  export MAYBE_SUDO=""
fi

if [ -t 1 ]; then
  export NORMAL="$(tput sgr0)"
  export RED="$(tput setaf 1)"
  export GREEN="$(tput setaf 2)"
  export MAGENTA="$(tput setaf 5)"
  export CYAN="$(tput setaf 6)"
  export WHITE="$(tput setaf 7)"
  export BOLD="$(tput bold)"
else
  export NORMAL=""
  export RED=""
  export GREEN=""
  export MAGENTA=""
  export CYAN=""
  export WHITE=""
  export BOLD=""
fi

error_exit() {
  echo "${RED}${BOLD}ERROR${NORMAL}${BOLD}: $1${NORMAL}"
  shift
  while [ "$#" -gt "0" ]; do
    echo " - $1"
    shift
  done
  exit 1
}

log_step() {
  echo ''
  echo "${GREEN}${BOLD}INFO${NORMAL}${BOLD}: $1${NORMAL}"
  shift
  while [ "$#" -gt "0" ]; do
    echo " - $1"
    shift
  done
}

log_warn() {
  echo ''
  echo "${GREEN}${BOLD}INFO${NORMAL}${BOLD}: $1${NORMAL}"
  shift
  while [ "$#" -gt "0" ]; do
    echo " - $1"
    shift
  done
}

command_present() {
    type "$1" >/dev/null 2>&1
}

log_step 'Starting Humongous...'

# NB: awk is to remove whitespace from `wc`
HUMONGOUS_PROCESSES="$($MAYBE_SUDO docker ps | (grep 'humongous' || true) | wc -l | awk '{print $1}')"

if test "$HUMONGOUS_PROCESSES" -gt '0'; then
  log_warn "Humongous is already started. Restarting..."
  echo ""
fi

$MAYBE_SUDO docker compose up -d

echo ""
echo "${CYAN}Navigate to${NORMAL}:"
echo "  - ${WHITE}http://127.0.0.1:8080/app"
echo "  - http://${WHITE}[public_ip]:8080/app"
echo ""
echo "${CYAN}To STOP Humongous, run${NORMAL}: ${WHITE}${BOLD}./stop${NORMAL}"
echo "${CYAN}To RESTART Humongous, run${NORMAL}: ${WHITE}${BOLD}./start${NORMAL}"
echo ""