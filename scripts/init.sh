#!/bin/bash
set -e

echo "=== Initializing Face Recognition Service ==="

# ==========================
# Konfiguration
# ==========================
REGION="us-east-1"
LAMBDA_NAME="m346-face-recognition"
ROLE_NAME="LabRole"
RUNTIME="python3.9"
HANDLER="lambda_function.lambda_handler"
ZIP_FILE="lambda.zip"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

IN_BUCKET="m346-face-recognition-in-$ACCOUNT_ID"
OUT_BUCKET="m346-face-recognition-out-$ACCOUNT_ID"

echo "AWS Account : $ACCOUNT_ID"
echo "Region      : $REGION"
echo "In-Bucket   : $IN_BUCKET"
echo "Out-Bucket  : $OUT_BUCKET"
echo ""

# ==========================
# Funktion: S3 Bucket erstellen
# ==========================
create_bucket() {
  BUCKET=$1

  if aws s3 ls "s3://$BUCKET" >/dev/null 2>&1; then
    echo "Bucket $BUCKET already exists"
  else
    echo "Creating bucket $BUCKET"
    aws s3api create-bucket \
      --bucket "$BUCKET" \
      --region "$REGION"
    echo "Bucket $BUCKET created"
  fi
}

# ==========================
# 1. Buckets erstellen
# ==========================
create_bucket "$IN_BUCKET"
create_bucket "$OUT_BUCKET"
echo ""

# ==========================
# 2. Lambda ZIP bauen
# ==========================
echo "Packaging Lambda function..."

if [ ! -f src/lambda_function.py ]; then
  echo "ERROR: src/lambda_function.py not found"
  exit 1
fi

zip -j "$ZIP_FILE" src/lambda_function.py >/dev/null
echo "Lambda package created: $ZIP_FILE"
echo ""

# ==========================
# 3. Lambda erstellen oder updaten
# ==========================
if aws lambda get-function \
  --function-name "$LAMBDA_NAME" \
  --region "$REGION" >/dev/null 2>&1; then

  echo "Updating existing Lambda function..."
  aws lambda update-function-code \
    --function-name "$LAMBDA_NAME" \
    --zip-file "fileb://$ZIP_FILE" \
    --region "$REGION"
else
  echo "Creating Lambda function..."
  aws lambda create-function \
    --function-name "$LAMBDA_NAME" \
    --runtime "$RUNTIME" \
    --role "arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" \
    --handler "$HANDLER" \
    --zip-file "fileb://$ZIP_FILE" \
    --region "$REGION"
fi

# ==========================
# 4. Environment Variable setzen
# ==========================
echo "Configuring Lambda environment variables..."

aws lambda update-function-configuration \
  --function-name "$LAMBDA_NAME" \
  --environment "Variables={OUT_BUCKET=$OUT_BUCKET}" \
  --region "$REGION"

# ==========================
# 5. Warten bis Lambda ACTIVE
# ==========================
echo "Waiting for Lambda to become ACTIVE..."
aws lambda wait function-active \
  --function-name "$LAMBDA_NAME" \
  --region "$REGION"

# ==========================
# 6. Lambda ARN holen
# ==========================
LAMBDA_ARN=$(aws lambda get-function \
  --function-name "$LAMBDA_NAME" \
  --region "$REGION" \
  --query 'Configuration.FunctionArn' \
  --output text)

echo "Lambda ARN: $LAMBDA_ARN"
echo ""

# ==========================
# 7. S3 → Lambda Invoke-Permission
# ==========================
echo "Adding S3 invoke permission..."

aws lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --statement-id "s3invoke-$IN_BUCKET" \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --source-arn "arn:aws:s3:::$IN_BUCKET" \
  --region "$REGION" \
  >/dev/null 2>&1 || true

# ==========================
# 8. S3 Trigger konfigurieren
# ==========================
echo "Configuring S3 trigger..."

aws s3api put-bucket-notification-configuration \
  --bucket "$IN_BUCKET" \
  --notification-configuration "{
    \"LambdaFunctionConfigurations\": [{
      \"LambdaFunctionArn\": \"$LAMBDA_ARN\",
      \"Events\": [\"s3:ObjectCreated:*\"],
      \"Filter\": {
        \"Key\": {
          \"FilterRules\": [{
            \"Name\": \"prefix\",
            \"Value\": \"uploads/\"
          }]
        }
      }
    }]
  }" \
  --region "$REGION"

echo ""
echo "=== init.sh completed successfully ==="
