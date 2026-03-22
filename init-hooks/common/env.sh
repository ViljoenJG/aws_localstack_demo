#!/bin/bash
# Shared environment variables for init-hook scripts.
# Source this file at the top of each ready.d script.

export REGION="eu-central-1"
export TABLE_NAME="Items"
export STAGE="prod"
export LAMBDA_ROLE="arn:aws:iam::000000000000:role/lambda-role"

# Shared state directory for passing data between scripts
export INIT_STATE_DIR="/tmp/init-state"
mkdir -p "$INIT_STATE_DIR"
