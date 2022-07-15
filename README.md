# Deploying Humongous on-premise

Deploying Humongous on-premise ensures that access to your databases happens only within your own cloud environment. You also have the flexibility to control how Humongous is setup within your infrastructure, and enable custom SAML SSO using providers like Okta and Active Directory.

## General system requirements

- Linux Virtual Machine
  - Ubuntu `16.04` or higher
- `2` vCPUs
- `8` GiB + of Memory
- `40` GiB + of Storage
- Networking Requirements for Initial Setup:
  - `80` (http): for connecting to the server from the browser
  - `443` (https): for connecting to the server from the browser
  - `22` (SSH): To allow you to SSH into your instance and configure it
  - `8080` (Humongous): This is the default port Humongous runs on

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/eldonlabs/humongous-onpremise/main/install.sh)"