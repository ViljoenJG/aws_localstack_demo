const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  PutCommand,
  DeleteCommand,
} = require("@aws-sdk/lib-dynamodb");
const { randomUUID } = require("crypto");

const clientConfig = {};
if (process.env.AWS_ENDPOINT_URL) {
  clientConfig.endpoint = process.env.AWS_ENDPOINT_URL;
}
const client = new DynamoDBClient(clientConfig);
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME || "Items";

const response = (status, body) => ({
  statusCode: status,
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(body),
});

exports.createItem = async (event) => {
  const body = JSON.parse(event.body || "{}");
  const item = {
    ...body,
    name: body.name || "Unnamed",
    createdAt: new Date().toISOString(),
    id: randomUUID(),
  };

  // item.id = randomUUID();

  await docClient.send(
    new PutCommand({
      TableName: TABLE_NAME,
      Item: item,
    }),
  );

  return response(201, item);
};

exports.deleteItem = async (event) => {
  const itemId = event.pathParameters.id;

  await docClient.send(
    new DeleteCommand({
      TableName: TABLE_NAME,
      Key: { id: itemId },
    }),
  );

  return response(200, { message: `Item ${itemId} deleted` });
};
