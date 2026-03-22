import * as dynamodb from "aws-cdk-lib/aws-dynamodb";
import * as lambda from "aws-cdk-lib/aws-lambda";
import { Construct } from "constructs";
import * as path from "path";

export class LambdaConstruct extends Construct {
  public readonly listItems: lambda.Function;
  public readonly getItem: lambda.Function;
  public readonly createItem: lambda.Function;
  public readonly deleteItem: lambda.Function;

  constructor(scope: Construct, id: string, table: dynamodb.Table) {
    super(scope, id);

    // Read Lambdas (Python)
    this.listItems = new lambda.Function(this, "ListItemsFunction", {
      functionName: "list-items",
      runtime: lambda.Runtime.PYTHON_3_13,
      handler: "handler.list_items",
      code: lambda.Code.fromAsset(path.join(__dirname, "../../../lambdas/read-items")),
      environment: { TABLE_NAME: table.tableName },
    });

    this.getItem = new lambda.Function(this, "GetItemFunction", {
      functionName: "get-item",
      runtime: lambda.Runtime.PYTHON_3_13,
      handler: "handler.get_item",
      code: lambda.Code.fromAsset(path.join(__dirname, "../../../lambdas/read-items")),
      environment: { TABLE_NAME: table.tableName },
    });

    // Write Lambdas (Node.js)
    this.createItem = new lambda.Function(this, "CreateItemFunction", {
      functionName: "create-item",
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: "handler.createItem",
      code: lambda.Code.fromAsset(path.join(__dirname, "../../../lambdas/write-items")),
      environment: { TABLE_NAME: table.tableName },
    });

    this.deleteItem = new lambda.Function(this, "DeleteItemFunction", {
      functionName: "delete-item",
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: "handler.deleteItem",
      code: lambda.Code.fromAsset(path.join(__dirname, "../../../lambdas/write-items")),
      environment: { TABLE_NAME: table.tableName },
    });

    // Grant DynamoDB access
    table.grantReadData(this.listItems);
    table.grantReadData(this.getItem);
    table.grantWriteData(this.createItem);
    table.grantWriteData(this.deleteItem);
  }
}
