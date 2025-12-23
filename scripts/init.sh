#!/bin/bash
set -e

echo "Initializing Face Recognition Service"

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

IN_BUCKET="m346-face-recognition-in-$ACCOUNT_ID"
OUT_BUCKET="m346-face-recognition-out-$ACCOUNT_ID"
