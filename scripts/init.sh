#!/bin/bash
set -e

echo "Initializing Face Recognition Service"

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

IN_BUCKET="m346-face-recognition-in-$ACCOUNT_ID"
OUT_BUCKET="m346-face-recognition-out-$ACCOUNT_ID"

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
