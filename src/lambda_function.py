import urllib.parse
import json
import boto3
import os

s3 = boto3.client("s3")
rekognition = boto3.client("rekognition")

OUT_BUCKET = os.environ["OUT_BUCKET"]

def lambda_handler(event, context):
    # S3-Event lesen
    record = event["Records"][0]
    in_bucket = record["s3"]["bucket"]["name"]
    object_key = urllib.parse.unquote_plus(
        record["s3"]["object"]["key"]
    )

    # Nur uploads/ verarbeiten
    if not object_key.startswith("uploads/"):
        return {
            "statusCode": 200,
            "message": "File ignored (not in uploads/)"
        }

    # Rekognition aufrufen
    response = rekognition.recognize_celebrities(
        Image={
            "S3Object": {
                "Bucket": in_bucket,
                "Name": object_key
            }
        }
    )

    celebrities = []
    for celeb in response.get("CelebrityFaces", []):
        celebrities.append({
            "name": celeb["Name"],
            "confidence": round(celeb["MatchConfidence"], 2),
            "urls": celeb.get("Urls", [])
        })

    result = {
        "input_bucket": in_bucket,
        "input_file": object_key,
        "celebrity_count": len(celebrities),
        "celebrities": celebrities
    }

    # JSON-Dateiname erzeugen
    json_key = object_key.replace(
        "uploads/", "results/"
    ).rsplit(".", 1)[0] + ".json"

    # JSON im Out-Bucket speichern
    s3.put_object(
        Bucket=OUT_BUCKET,
        Key=json_key,
        Body=json.dumps(result, indent=2),
        ContentType="application/json"
    )

    return {
        "statusCode": 200,
        "message": "Recognition completed",
        "output_file": json_key
    }
