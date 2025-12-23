import urllib.parse
import boto3

rekognition = boto3.client("rekognition")

def lambda_handler(event, context):
    # S3-Event lesen
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

    # Rekognition: bekannte Persönlichkeiten erkennen
    response = rekognition.recognize_celebrities(
        Image={
            "S3Object": {
                "Bucket": bucket_name,
                "Name": object_key
            }
        }
    )

    celebrities = []
    for celeb in response.get("CelebrityFaces", []):
        celebrities.append({
            "name": celeb["Name"],
            "confidence": round(celeb["MatchConfidence"], 2)
        })

    return {
        "statusCode": 200,
        "input_file": object_key,
        "celebrity_count": len(celebrities),
        "celebrities": celebrities
    }
