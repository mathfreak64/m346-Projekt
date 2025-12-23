#!/bin/bash
set -e

# Verhindert das Hängenbleiben in der Konsole
export AWS_PAGER=""

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

IN_BUCKET="m346-face-recognition-in-$ACCOUNT_ID"
OUT_BUCKET="m346-face-recognition-out-$ACCOUNT_ID"

# Pfade zu den Testdateien
TEST_IMAGE="test/test.jpg"
UPLOAD_KEY="uploads/test.jpg"

echo "=== Starting Face Recognition Service Test ==="
echo "AWS Account : $ACCOUNT_ID"

# 1. Testbild prüfen
if [ ! -f "$TEST_IMAGE" ]; then
  echo "ERROR: Test image not found at $TEST_IMAGE"
  exit 1
fi

# 2. Testbild hochladen
echo "Uploading test image to s3://$IN_BUCKET/$UPLOAD_KEY ..."
aws s3 cp "$TEST_IMAGE" "s3://$IN_BUCKET/$UPLOAD_KEY" --region "$REGION"