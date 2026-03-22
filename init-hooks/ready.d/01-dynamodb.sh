#!/bin/bash
set -euo pipefail
source /etc/localstack/init/common/env.sh

echo "============================================"
echo "  Creating DynamoDB table: $TABLE_NAME"
echo "============================================"

awslocal dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "DynamoDB table created."
