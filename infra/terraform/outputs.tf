output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_deployment.demo.invoke_url}${var.stage_name}"
}

output "api_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.demo.id
}

output "dynamodb_table" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.items.name
}

output "localstack_url" {
  description = "LocalStack API URL (for local testing)"
  value       = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.demo.id}/${var.stage_name}/_user_request_/items"
}
