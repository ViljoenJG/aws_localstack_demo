#!/bin/bash
set -euo pipefail
source /etc/localstack/init/common/env.sh

echo "============================================"
echo "  Deploying Lambda functions"
echo "============================================"

# --- Python Lambdas ---
echo "Packaging Python Lambdas..."
cd /opt/lambdas/read-items
zip -j /tmp/python-lambda.zip handler.py

echo "Deploying list-items Lambda..."
awslocal lambda create-function \
  --function-name list-items \
  --runtime python3.13 \
  --handler handler.list_items \
  --zip-file fileb:///tmp/python-lambda.zip \
  --role "$LAMBDA_ROLE" \
  --environment "Variables={TABLE_NAME=$TABLE_NAME}" \
  --region "$REGION"

echo "Deploying get-item Lambda..."
awslocal lambda create-function \
  --function-name get-item \
  --runtime python3.13 \
  --handler handler.get_item \
  --zip-file fileb:///tmp/python-lambda.zip \
  --role "$LAMBDA_ROLE" \
  --environment "Variables={TABLE_NAME=$TABLE_NAME}" \
  --region "$REGION"

# --- Node.js Lambdas ---
echo "Packaging Node.js Lambdas..."
cd /opt/lambdas/write-items
npm install --omit=dev 2>/dev/null || true
zip -r /tmp/node-lambda.zip handler.js node_modules/ package.json

echo "Deploying create-item Lambda..."
awslocal lambda create-function \
  --function-name create-item \
  --runtime nodejs20.x \
  --handler handler.createItem \
  --zip-file fileb:///tmp/node-lambda.zip \
  --role "$LAMBDA_ROLE" \
  --environment "Variables={TABLE_NAME=$TABLE_NAME}" \
  --region "$REGION"

echo "Deploying delete-item Lambda..."
awslocal lambda create-function \
  --function-name delete-item \
  --runtime nodejs20.x \
  --handler handler.deleteItem \
  --zip-file fileb:///tmp/node-lambda.zip \
  --role "$LAMBDA_ROLE" \
  --environment "Variables={TABLE_NAME=$TABLE_NAME}" \
  --region "$REGION"

echo "All Lambda functions deployed."
