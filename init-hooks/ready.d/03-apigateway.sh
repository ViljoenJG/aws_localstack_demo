#!/bin/bash
set -euo pipefail
source /etc/localstack/init/common/env.sh

echo "============================================"
echo "  Creating API Gateway"
echo "============================================"

API_ID=$(awslocal apigateway create-rest-api \
  --name "items-api" \
  --region "$REGION" \
  --query 'id' --output text)

ROOT_ID=$(awslocal apigateway get-resources \
  --rest-api-id "$API_ID" \
  --region "$REGION" \
  --query 'items[0].id' --output text)

# Create /items resource
ITEMS_ID=$(awslocal apigateway create-resource \
  --rest-api-id "$API_ID" \
  --parent-id "$ROOT_ID" \
  --path-part "items" \
  --region "$REGION" \
  --query 'id' --output text)

# Create /items/{id} resource
ITEM_ID=$(awslocal apigateway create-resource \
  --rest-api-id "$API_ID" \
  --parent-id "$ITEMS_ID" \
  --path-part "{id}" \
  --region "$REGION" \
  --query 'id' --output text)

# GET /items → list-items
awslocal apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEMS_ID" \
  --http-method GET \
  --authorization-type NONE \
  --region "$REGION"

awslocal apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEMS_ID" \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:list-items/invocations" \
  --region "$REGION"

# POST /items → create-item
awslocal apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEMS_ID" \
  --http-method POST \
  --authorization-type NONE \
  --region "$REGION"

awslocal apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEMS_ID" \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:create-item/invocations" \
  --region "$REGION"

# GET /items/{id} → get-item
awslocal apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEM_ID" \
  --http-method GET \
  --authorization-type NONE \
  --region "$REGION"

awslocal apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEM_ID" \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:get-item/invocations" \
  --region "$REGION"

# DELETE /items/{id} → delete-item
awslocal apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEM_ID" \
  --http-method DELETE \
  --authorization-type NONE \
  --region "$REGION"

awslocal apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$ITEM_ID" \
  --http-method DELETE \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:delete-item/invocations" \
  --region "$REGION"

# Deploy the API
awslocal apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name "$STAGE" \
  --region "$REGION"

# Save API_ID for downstream scripts
echo "$API_ID" > "$INIT_STATE_DIR/api_id"

echo "API Gateway created and deployed (API_ID: $API_ID)."
