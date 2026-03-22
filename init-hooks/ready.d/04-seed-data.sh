#!/bin/bash
set -euo pipefail
source /etc/localstack/init/common/env.sh

echo "============================================"
echo "  Seeding demo data"
echo "============================================"

awslocal dynamodb put-item \
  --table-name "$TABLE_NAME" \
  --item '{"id":{"S":"seed-001"},"name":{"S":"Widget Alpha"},"createdAt":{"S":"2026-01-15T10:00:00Z"}}' \
  --region "$REGION"

awslocal dynamodb put-item \
  --table-name "$TABLE_NAME" \
  --item '{"id":{"S":"seed-002"},"name":{"S":"Widget Beta"},"createdAt":{"S":"2026-02-20T14:30:00Z"}}' \
  --region "$REGION"

echo "Demo data seeded."

# Print summary
API_ID=$(cat "$INIT_STATE_DIR/api_id")
API_URL="https://$API_ID.execute-api.localhost.localstack.cloud:4566/$STAGE/"

echo ""
echo "============================================"
echo "  Demo environment ready!"
echo ""
echo "  API URL: $API_URL"
echo ""
echo "  Try:"
echo "    curl $API_URL/items"
echo "    curl -X POST $API_URL/items -d '{\"name\":\"My Item\"}'"
echo "============================================"
