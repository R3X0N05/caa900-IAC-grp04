#!/bin/bash
set -e
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
BUCKET="rexony-tfstate-${ACCOUNT_ID}"
TABLE="rexony-tfstate-lock"

echo "Creating S3 state bucket: $BUCKET"
aws s3 mb "s3://${BUCKET}" --region ${REGION}
aws s3api put-bucket-versioning --bucket ${BUCKET} \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket ${BUCKET} \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Creating DynamoDB lock table: $TABLE"
aws dynamodb create-table \
  --table-name ${TABLE} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ${REGION}

echo ""
echo "Done. Set this in main.tf backend block:"
echo "  bucket = \"${BUCKET}\""