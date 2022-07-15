#!/usr/bin/env bash

# See https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail

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

INSTALL_DIRECTORY="humongous"

if [ -d "$INSTALL_DIRECTORY" ]; then
    error_exit "found a directory called $INSTALL_DIRECTORY. Remove it before proceeding..."
fi

log_step 'setting up install location...' "$INSTALL_DIRECTORY"

if ! command_present unzip; then
  log_warn '`unzip` not found!'
  log_warn 'Attempting to git clone instead'
  if command_present git; then
    log_step 'cloning...'
    git clone https://github.com/eldonlabs/humongous-onpremise.git
  elif command_present yum; then
    log_warn 'You did not have git so installing'
    sudo yum install git
    git clone https://github.com/eldonlabs/humongous-onpremise.git
  else
    error_exit "Please install git or unzip before continuing"
  fi
  mv humongous-onpremise "$INSTALL_DIRECTORY"
else
  log_step 'downloading...'
  curl -L -XGET -o main.zip https://github.com/eldonlabs/humongous-onpremise/archive/refs/heads/main.zip
  log_step 'unpacking...'
  unzip main.zip
  mv humongous-onpremise-main "$INSTALL_DIRECTORY"
fi

cd "$INSTALL_DIRECTORY"

# Install docker.
if ! command_present docker; then
  log_warn '`docker` not found! Attempting to install. This may take a few minutes.'
  
  ./get-docker.sh

  if ! command_present docker; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      error_exit "please install \`docker\` manually" \
        "Instructions can be found at ${WHITE}${BOLD}https://docs.docker.com/${NORMAL}" \
        "${BOLD}Remember${NORMAL} to start the \`Docker\` app from the UI."
    else
      error_exit "please install \`docker\` manually" \
        "Instructions can be found at ${WHITE}${BOLD}https://docs.docker.com/${NORMAL}" \
        "${BOLD}Remember${NORMAL} to start the \`docker\` daemon/service."
    fi
  fi
else
  log_step '`docker` found!'
fi  

log_step "Building Humongous!"
$MAYBE_SUDO docker compose up -d