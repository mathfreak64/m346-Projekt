import urllib.parse

def lambda_handler(event, context):
    # S3-Event auslesen
    record = event["Records"][0]
    bucket_name = record["s3"]["bucket"]["name"]
    object_key = urllib.parse.unquote_plus(
        record["s3"]["object"]["key"]
    )

    # Nur uploads/ verarbeiten
    if not object_key.startswith("uploads/"):
        return {
            "statusCode": 200,
            "message": "File ignored (not in uploads/)"
        }

    return {
        "statusCode": 200,
        "message": "S3 upload event received",
        "bucket": bucket_name,
        "file": object_key
    }
