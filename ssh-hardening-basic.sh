#!/bin/bash

# ============================
#  Laravel Forge SSH Hardening
# ============================

# Variables
SSH_CONFIG="/etc/ssh/sshd_config"
SSH_PORT=2222  # Change SSH port
API_KEY="your-forge-api-key"  # Replace with your Forge API Key
IP_LIST_URL="https://forge.laravel.com/ips-v4.txt"
HOSTNAME=$(hostname)
ALLOWED_IPS=()

# ============================
#   Get Laravel Forge Server ID (Using Hostname)
# ============================
echo "Fetching Forge Server ID..."

SERVER_ID=$(curl -s -H "Authorization: Bearer $API_KEY" -H "Accept: application/json" \
            https://forge.laravel.com/api/v1/servers | \
            jq -r --arg hostname "$HOSTNAME" '.servers[] | select(.name == $hostname) | .id')

if [[ -z "$SERVER_ID" ]]; then
    echo "Error: Could not retrieve Server ID for hostname '$HOSTNAME' from Forge API."
    exit 1
fi

echo "Server ID: $SERVER_ID"

echo "Starting SSH hardening..."

# Backup SSH config
cp $SSH_CONFIG ${SSH_CONFIG}.bak

# Update SSH settings: disable password authentication, change port
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' "$SSH_CONFIG"
sed -i 's/#Port 22/Port 2222/g' "$SSH_CONFIG"

echo "SSH configured: PasswordAuthentication disabled, Port changed to $SSH_PORT."

# Function to add firewall rule via API
add_firewall_rule() {
  local ip="$1"
  local port="$2"
  local name="$3"
  local type="$4"
  
  echo "Payload:"
  echo "{
        \"name\": \"$name\",
        \"ip_address\": \"$ip\",
        \"port\": \"$port\",
        \"type\": \"$type\"
      }"

  curl -s -X POST "https://forge.laravel.com/api/v1/servers/$SERVER_ID/firewall-rules" \
       -H "Authorization: Bearer $API_KEY" \
       -H "Accept: application/json" \
       -d "{
             \"name\": \"$name\",
             \"ip_address\": \"$ip\",
             \"port\": \"$port\",
             \"type\": \"$type\"
           }"
}

# Fetch allowed IPs from the URL and apply firewall rules via API
curl -s "$IP_LIST_URL" | while read -r ip; do
  if [[ ! -z "$ip" ]]; then
    echo "Allowing IP $ip on port $SSH_PORT"
    add_firewall_rule "$ip" 2222 "Allow Forge SSH" "allow" # Add firewall rule for each IP
  fi
done

# Alternatively, use the ALLOWED_IPS array
for ip in "${ALLOWED_IPS[@]}"; do
  echo "Allowing IP $ip on port $SSH_PORT"
  add_firewall_rule "$ip" 2222 "Allow Cox SSH" "allow" # Add firewall rule for each allowed IP
done

echo "Rebooting the server now..."
reboot
