#!/bin/bash

# Color definitions
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

# Check if script is running as root
function check_root() {
  if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (with sudo)${RESET}"
    echo -e "${YELLOW}Please run: sudo $0${RESET}"
    exit 1
  fi
}

# ASCII Art for fun
function print_banner() {
  clear -x
  echo -e "${CYAN}"
  echo "==============================================="
  echo "         🎉 Certificate Creator 3000 🎉        "
  echo "==============================================="
  echo -e "${RESET}"
}

# Get user input for the domain
function get_user_input() {
  echo -e "${YELLOW}Please provide the following details:${RESET}"
  read -p "Domain name (e.g., yourdomain.local): " DOMAIN_NAME
  read -p "Country Code (e.g., US): " COUNTRY
  read -p "State (e.g., State): " STATE
  read -p "City (e.g., City): " CITY
  read -p "Organization (e.g., HomeNetwork): " ORGANIZATION
  read -p "Organizational Unit (e.g., IT): " ORG_UNIT
  echo -e "${GREEN}Thank you! Let's get started...${RESET}"
}

# New function to handle certificate installation
function install_certificate() {
  echo -e "${YELLOW}Would you like to install the CA certificate system-wide? (y/N)${RESET}"
  read -r INSTALL_CHOICE
  
  if [[ "${INSTALL_CHOICE,,}" == "y" ]]; then
    echo -e "${CYAN}Installing the CA certificate...${RESET}"
    sudo cp $CA_CERT /usr/local/share/ca-certificates/
    sudo update-ca-certificates
    echo -e "${GREEN}CA certificate installed successfully!${RESET}"
  else
    echo -e "${YELLOW}Skipping CA certificate installation.${RESET}"
    echo -e "${CYAN}Note: You can manually install the certificate later using:${RESET}"
    echo "sudo cp $CA_CERT /usr/local/share/ca-certificates/"
    echo "sudo update-ca-certificates"
  fi
}

# Main function to create certificates
function create_certificates() {
  local CA_KEY="myCA.key"
  local CA_CERT="myCA.pem"
  local DOMAIN_KEY="${DOMAIN_NAME}.key"
  local DOMAIN_CSR="${DOMAIN_NAME}.csr"
  local DOMAIN_CERT="${DOMAIN_NAME}.crt"
  local CSR_CNF="${DOMAIN_NAME}.csr.cnf"
  local EXT_FILE="v3.ext"
  local DAYS_CA=1825
  local DAYS_CERT=825

  print_banner

  # Step 1: Create CA private key
  echo -e "${CYAN}Creating CA private key...${RESET}"
  openssl genrsa -out $CA_KEY 2048

  # Step 2: Create self-signed root certificate
  echo -e "${CYAN}Creating self-signed root certificate...${RESET}"
  openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days $DAYS_CA -out $CA_CERT -subj "/CN=MyLocalCA"

  # Step 3: Create private key for the domain
  echo -e "${CYAN}Creating private key for the domain...${RESET}"
  openssl genrsa -out $DOMAIN_KEY 2048

  # Step 4: Create CSR configuration file
  echo -e "${CYAN}Creating CSR configuration file...${RESET}"
  cat > $CSR_CNF <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=$COUNTRY
ST=$STATE
L=$CITY
O=$ORGANIZATION
OU=$ORG_UNIT
CN=*.${DOMAIN_NAME}
EOF

  # Step 5: Create extensions file
  echo -e "${CYAN}Creating extensions file...${RESET}"
  cat > $EXT_FILE <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.${DOMAIN_NAME}
DNS.2 = ${DOMAIN_NAME}
EOF

  # Step 6: Generate the CSR
  echo -e "${CYAN}Generating CSR...${RESET}"
  openssl req -new -key $DOMAIN_KEY -out $DOMAIN_CSR -config $CSR_CNF

  # Step 7: Sign the certificate
  echo -e "${CYAN}Signing the certificate...${RESET}"
  openssl x509 -req -in $DOMAIN_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $DOMAIN_CERT -days $DAYS_CERT -sha256 -extfile $EXT_FILE

  # Replace the existing installation step with the new function call
  install_certificate

  echo -e "${GREEN}🎉 Certificate creation completed successfully! 🎉${RESET}"
}

# Execution starts here
check_root
print_banner
get_user_input
create_certificates