# Basic SSH Hardening Forge Recipe

This script automates the process of hardening SSH access on a Laravel Forge server by making the following changes:
- Disables password authentication for SSH.
- Changes the default SSH port from `22` to `2222`.
- Adds firewall rules to allow Forge IPs to new SSH port.
- Adds firewall rules to allow a custom list of IPs to new SSH port.
- Reboots the server

## Mandatory Steps After Running
**You must modify server settings to update the SSH port after running this recipe script!.** You may also delete the `Allow * 22` firewall rule once complete.

## Prerequisites

Before using this script, ensure that you have:
- A Laravel Forge server set up with `jq` and `curl` installed.
- A Forge API key with sufficient permissions.

### Setup Instructions

1. **Set Your Forge API Key**
   - Replace the `API_KEY` variable in the script with your actual Forge API key:
   ```bash
   API_KEY="your-forge-api-key"
   ```

2. **Update Allowed IPs**

    You can modify the ALLOWED_IPS array in the script to include the IP ranges or specific IPs that should be allowed SSH access.

    ```bash
    ALLOWED_IPS=("10.10.0.1/20" "10.20.0.1/20")
    ```
3. **Change the New SSH Port (optional)**

    You can modify the new SSH port from the default `2222`.
    ```bash
    SSH_PORT="223"
    ```

## License
This script is provided as-is. Use at your own risk, and ensure you've backed up critical server configurations before applying changes.
