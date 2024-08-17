#!/bin/bash

# Function to show help
show_help() {
  echo "Usage: sudo $0 -p port [-r] [-h]"
  echo ""
  echo "   -p port   Specify the port to apply the rules (required)"
  echo "   -r        Remove rules for the specified port"
  echo "   -h        Display this help message"
  echo ""
  echo "Example usage:"
  echo "Add rules: ./script.sh -p 80"
  echo "Remove rules: ./script.sh -p 80 -r"
}

# Check if no arguments were passed
if [ $# -eq 0 ]; then
  show_help
  exit 1
fi

# Parse arguments
REMOVE_RULES=false
PORT=""

while getopts ":p:rh" opt; do
  case ${opt} in
    p )
      PORT=$OPTARG
      ;;
    r )
      REMOVE_RULES=true
      ;;
    h )
      show_help
      exit 0
      ;;
    \? )
      echo "Invalid option: -$OPTARG" >&2
      show_help
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." >&2
      show_help
      exit 1
      ;;
  esac
done

# Ensure port is specified
if [ -z "$PORT" ]; then
  echo "Port (-p) is required." >&2
  show_help
  exit 1
fi

# Function to add rules
add_rules() {
  for i in \
    173.245.48.0/20 \
    103.21.244.0/22 \
    103.22.200.0/22 \
    103.31.4.0/22 \
    141.101.64.0/18 \
    108.162.192.0/18 \
    190.93.240.0/20 \
    188.114.96.0/20 \
    197.234.240.0/22 \
    198.41.128.0/17 \
    162.158.0.0/15 \
    104.16.0.0/13 \
    104.24.0.0/14 \
    172.64.0.0/13 \
    131.0.72.0/22; do
    iptables -I INPUT -p tcp -m multiport --dports $PORT -s $i -j ACCEPT
  done

  iptables -A INPUT -p tcp -m multiport --dports $PORT -j DROP
}

# Function to remove rules
remove_rules() {
  for i in \
    173.245.48.0/20 \
    103.21.244.0/22 \
    103.22.200.0/22 \
    103.31.4.0/22 \
    141.101.64.0/18 \
    108.162.192.0/18 \
    190.93.240.0/20 \
    188.114.96.0/20 \
    197.234.240.0/22 \
    198.41.128.0/17 \
    162.158.0.0/15 \
    104.16.0.0/13 \
    104.24.0.0/14 \
    172.64.0.0/13 \
    131.0.72.0/22; do
    iptables -D INPUT -p tcp -m multiport --dports $PORT -s $i -j ACCEPT
  done

  iptables -D INPUT -p tcp -m multiport --dports $PORT -j DROP
}

# Execute the appropriate function
if [ "$REMOVE_RULES" = true ]; then
  remove_rules
else
  add_rules
fi
