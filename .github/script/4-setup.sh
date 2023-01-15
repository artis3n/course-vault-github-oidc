#!/usr/bin/env sh

set -eu

# Install Vault binary
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault=1.12.2-1

# Initialize Vault for this scenario
vault login vaultiscool
vault auth enable -path=gha jwt
vault write auth/gha/config \
bound_issuer="https://token.actions.githubusercontent.com" \
oidc_discovery_url="https://token.actions.githubusercontent.com"

# Create a secret
vault kv put secret/staging access_token=abc123
vault kv put secret/production access_token=xyz456
# Add OIDC policies
vault policy write staging-policy - << EOF
path "secret/data/staging" {
  capabilities = ["read"]
}
EOF
vault policy write prod-policy - << EOF
path "secret/data/production" {
  capabilities = ["read"]
}
EOF
