#!/bin/bash

# Usage: ./check_status.sh

echo
echo "✅ Checking with Clumio to see if the S3-Gold policy has been updated...please wait" 
sleep 2
echo
curl -s --location 'https://us-east-1.api.clumio.com/policies/definitions?filter=%7B%22name%22%3A%7B%22%24eq%22%3A%22S3-Gold%22%7D%7D' \
-H "Authorization: Bearer ${CLUMIO_TOKEN}" | jq
echo
echo
echo "✅ Check complete, retention has been changed"
echo
echo "🎉 Congratulations, we have completed the demo 🎉"
echo
echo