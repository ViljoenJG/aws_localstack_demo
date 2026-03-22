import * as cdk from "aws-cdk-lib";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as apigateway from "aws-cdk-lib/aws-apigateway";
import { Construct } from "constructs";

export interface ApiGatewayConstructProps {
  listItems: lambda.Function;
  getItem: lambda.Function;
  createItem: lambda.Function;
  deleteItem: lambda.Function;
}

export class ApiGatewayConstruct extends Construct {
  public readonly api: apigateway.RestApi;

  constructor(scope: Construct, id: string, props: ApiGatewayConstructProps) {
    super(scope, id);

    this.api = new apigateway.RestApi(this, "ItemsApi", {
      restApiName: "items-api",
      description: "CRUD API for Items demo",
    });

    const items = this.api.root.addResource("items");
    items.addMethod("GET", new apigateway.LambdaIntegration(props.listItems));
    items.addMethod("POST", new apigateway.LambdaIntegration(props.createItem));

    const item = items.addResource("{id}");
    item.addMethod("GET", new apigateway.LambdaIntegration(props.getItem));
    item.addMethod("DELETE", new apigateway.LambdaIntegration(props.deleteItem));

    new cdk.CfnOutput(this, "ApiUrl", {
      value: this.api.url,
      description: "API Gateway endpoint URL",
    });
  }
}
