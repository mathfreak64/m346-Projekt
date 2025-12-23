#!/bin/bash
set -e

echo "=== Initializing Face Recognition Service ==="

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

IN_BUCKET="m346-face-recognition-in-$ACCOUNT_ID"
OUT_BUCKET="m346-face-recognition-out-$ACCOUNT_ID"

ZIP_FILE="lambda.zip"

echo "AWS Account : $ACCOUNT_ID"
echo "Region      : $REGION"
echo "In-Bucket   : $IN_BUCKET"
echo "Out-Bucket  : $OUT_BUCKET"
echo ""

# ==========================
# S3 Buckets
# ==========================
create_bucket() {
  BUCKET=$1
  if aws s3 ls "s3://$BUCKET" >/dev/null 2>&1; then
    echo "Bucket $BUCKET already exists"
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  fi
}

create_bucket "$IN_BUCKET"
create_bucket "$OUT_BUCKET"

# ==========================
# Lambda ZIP bauen
# ==========================
echo "Packaging Lambda function..."

if [ ! -f src/lambda_function.py ]; then
  echo "ERROR: src/lambda_function.py not found"
  exit 1
fi

zip -j "$ZIP_FILE" src/lambda_function.py >/dev/null
echo "Lambda package created: $ZIP_FILE"
