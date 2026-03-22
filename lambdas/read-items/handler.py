import json
import boto3
import os

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url=os.environ.get("AWS_ENDPOINT_URL"),
)
table = dynamodb.Table(os.environ.get("TABLE_NAME", "Items"))


def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def list_items(event, context):
    """GET /items — return all items."""
    result = table.scan()
    return response(200, result.get("Items", []))


def get_item(event, context):
    """GET /items/{id} — return a single item."""
    item_id = event["pathParameters"]["id"]
    result = table.get_item(Key={"id": item_id})
    item = result.get("Item")
    if not item:
        return response(404, {"error": "Item not found"})
    return response(200, item)
