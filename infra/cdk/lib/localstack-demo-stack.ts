import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { DynamoDbConstruct } from "./01-dynamodb";
import { LambdaConstruct } from "./02-lambda";
import { ApiGatewayConstruct } from "./03-apigateway";

export class LocalstackDemoStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const dynamo = new DynamoDbConstruct(this, "DynamoDB");
    const lambdas = new LambdaConstruct(this, "Lambda", dynamo.table);

    new ApiGatewayConstruct(this, "ApiGateway", {
      listItems: lambdas.listItems,
      getItem: lambdas.getItem,
      createItem: lambdas.createItem,
      deleteItem: lambdas.deleteItem,
    });
  }
}
