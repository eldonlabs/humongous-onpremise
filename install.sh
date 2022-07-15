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

INSTALL_DIRECTORY="humongous"

# Make sure wget is installed.
if ! command_present wget; then
  if command_present yum; then
    $MAYBE_SUDO yum install wget
  elif command_present apt-get; then
    $MAYBE_SUDO apt-get install wget
  fi
fi

# Let's make sure we do not override an existing installation of humongous-onpremise.
if [ -d "$INSTALL_DIRECTORY" ]; then
    error_exit "found a directory called $INSTALL_DIRECTORY. Remove it before proceeding..."
fi

log_step 'setting up install location...' "$INSTALL_DIRECTORY"

# Download humongous-onpremise repository.
if ! command_present unzip; then
  log_warn '`unzip` not found!'
  log_warn 'Attempting to git clone instead.'

  if command_present git; then
    log_step 'Cloning...'
    git clone https://github.com/eldonlabs/humongous-onpremise.git
  elif command_present yum; then
    log_warn 'You do not have git; Installing now...'
    $MAYBE_SUDO yum install git
    git clone https://github.com/eldonlabs/humongous-onpremise.git
  elif command_present apt-get; then
    log_warn 'You do not have git; Installing now...'
    $MAYBE_SUDO apt-get install git
    git clone https://github.com/eldonlabs/humongous-onpremise.git    
  else
    error_exit "Please install git or unzip before continuing."
  fi

  mv humongous-onpremise "$INSTALL_DIRECTORY"
else
  log_step 'Downloading...'
  wget https://github.com/eldonlabs/humongous-onpremise/archive/refs/heads/main.zip
  log_step 'Unpacking...'
  unzip main.zip
  mv humongous-onpremise-main "$INSTALL_DIRECTORY"
fi

cd "$INSTALL_DIRECTORY"

# Install docker.
if ! command_present docker; then
  log_warn '`docker` not found! Attempting to install. This may take a few minutes.'

  wget -qO- https://get.docker.com/ | sh

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

# Before creating the env file, let's make sure the user has a license key.
log_step "Enter your License key. Contact licensing@humongous.io if you do not have a key."
read -p "Enter it here: " licenseKey

if [[ "$licenseKey" == "" ]]; then
  error_exit "Please contact licensing@humongous.io to obtain your license key."
fi

# Create env file.
if [ -f ./.env ]; then
  mv .env .env.$(date +"%Y-%m-%d_%H-%M-%S")
fi
touch .env

echo 'NODE_ENV=onpremise' >> .env
echo '' >> .env

# DB info.
echo "# Database admin credentials for the app's data and logs." >> .env
echo "DB_ADMIN_USERNAME=hio" >> .env
echo "DB_ADMIN_PASSWORD=secret" >> .env
echo '' >> .env

# set up base domain.
echo '# Domain pointing to your Humongous deployment.' >> .env
echo "BASE_DOMAIN=http://127.0.0.1:8080" >> .env
echo '' >> .env

# Capture the license key.
echo '# License key.' >> .env
echo "LICENSE_KEY=${licenseKey}" >> .env
echo '' >> .env

# Cookie insecure value.
echo "# Sends auth requests with insecure cookies." >> .env
echo "# Set to true if hosting Humongous on a non-HTTPS URL or raw IP address." >> .env
echo "# This is typically used if you haven't deployed Humongous on a custom domain yet." >> .env
echo "COOKIE_INSECURE=true" >> .env

# Start the app.
./start.sh