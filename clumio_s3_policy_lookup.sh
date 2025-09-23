#!/usr/bin/env bash

# Usage: ./clumio_s3_policy_lookup.sh "S3-Gold"

POLICY_NAME="$1"  # Default policy name; can be overridden by command line arguments

if [ -z "$POLICY_NAME" ]; then
  echo "Usage: $0 <policy-name>"
  exit 1
fi

# Ensure required env vars are set
export CLUMIO_TOKEN:"eyJhbGciOiJSUzI1NiIsImtpZCI6IlpHTmlPREpoTkdZdE9URXpOQzAwT1RSaExUazNPVFl0TlRZM01EY3pZakJoWWpKbSIsInR5cCI6IkpXVCJ9.eyJjdXN0b206bmFtZSI6ImNpY2QiLCJjdXN0b206bnMiOiJwcm9kLTAyLXVlLTEiLCJjdXN0b206b3JnaWQiOiIxODg2NjY1OTI3NTU3Mjk4MDUiLCJjdXN0b206dXNlcmlkIjoiMTc3MDg0NzIwNDE2MjY2NDk3IiwiaWF0IjoxNzU3OTEzODU5LCJpc3MiOiJodHRwczovL3Byb2QtMDItdWUtMS1iYWNrZW5kLmFwaS5wcm9kLWNsdW1pby5jb20vYXBpL3Rva2Vucy9vcmdhbml6YXRpb25zLzE4ODY2NjU5Mjc1NTcyOTgwNSIsImp0aSI6ImRjYjgyYTRmLTkxMzQtNDk0YS05Nzk2LTU2NzA3M2IwYWIyZiIsInN1YiI6Ii90b2tlbnMvZGNiODJhNGYtOTEzNC00OTRhLTk3OTYtNTY3MDczYjBhYjJmIiwidG9rZW5fdXNlIjoiYWNjZXNzIn0.it7Ek6IdT3m2-hxGhRjDEz8KMsuwX3A_9bXk_vPe6sM16ywY7yxCSx213O6WFUUQKrS4WauWWpb4o0BnUNWGm5pqy6x_z0tGKAMWKiwy9uemB8p5SFz8vv266fCiM0gM1RjAAvH4axLmEYi4yPrRdD4pAFaMr4xRBG9627Xx6m35y-QbmwS19vYHOPx1rhb7FluqTkC62t7B7MaBfXfAdAmP-LJ3py_0aB_fHqqsGDXOYRips_AAYAC-MSmvAwaRWCVDZkmFGeymWFpXmYGpeN_nlCmD6bozmFJaLDnDmhf20GoL0CDkMigrJUgYJ8nx23sRbp55Rr6TVYzRcbEXDA"
export CLUMIO_REGION:"https://us-east-1.api.clumio.com/"
export CLUMIO_OU:"00000000-0000-0000-0000-000000000000"  # Default OU if not set

# Step 1: Get Policy ID and Operations
POLICY_JSON=$(curl -s -X GET \
  "https://${CLUMIO_REGION}.api.clumio.com/policies/definitions?filter=%7B%22name%22%3A%7B%22%24eq%22%3A%22POLICY_NAME%22%7D%7D \
  -H "Authorization: Bearer ${CLUMIO_TOKEN}" \
  -H "Accept: application/api.clumio.*=v1+json" \
  -H "X-Clumio-OrganizationalUnit-Context: ${CLUMIO_OU}")

POLICY_ID=$(echo "$POLICY_JSON" | jq -r '.embedded.items[].policy_id')

if [ -z "$POLICY_ID" ] || [ "$POLICY_ID" == "null" ]; then
  echo "❌ Policy '$POLICY_NAME' not found."
  exit 1
fi

echo "✅ Found Policy: $POLICY_NAME"
echo "   Policy ID: $POLICY_ID"
echo
echo "📋 Backup Settings:"
echo "$POLICY_JSON" | jq -r '.embedded.items[].operations[] | "   Type: \(.type), Interval: \(.backup_interval), Retention: \(.retention.value) \(.retention.unit)"'
echo

# Step 2: List S3 Buckets assigned to this policy
echo "🔎 S3 Buckets assigned to '$POLICY_NAME':"
curl -s -X GET \
  "https://${CLUMIO_REGION}.api.clumio.com/backups/aws/s3-buckets?filter=%7B%22name%22%3A%7B%22%24eq%22%3A%22POLICY_NAME%22%7D%7D \
  -H "Authorization: Bearer ${CLUMIO_TOKEN}" \
  -H "Accept: application/api.clumio.*=v1+json" \
  -H "X-Clumio-OrganizationalUnit-Context: ${CLUMIO_OU}" \
| jq -r '.embedded.items[] | "- \(.name) (Region: \(.region), Account: \(.aws_account_id))"'