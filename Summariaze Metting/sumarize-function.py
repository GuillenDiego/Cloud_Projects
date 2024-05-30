import boto3
import json
import os
import logging
from openai import OpenAI

# Configure logging
logging.basicConfig(level=logging.INFO)


def lambda_handler(event, context):
    try:
        # prompt = event['prompt']
        transcripts = event['results']['transcripts']
        s3bucket = event['s3bucket']
        s3_key = event['s3key']
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            raise ValueError("OpenAI API key not found.")
        client = OpenAI(api_key=api_key)
        messages = [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": f"Summarize the following transcript: {transcripts}"}
        ]
        completion = client.chat.completions.create(
            model="gpt-4", messages=messages, max_tokens=250)
        response = completion.choices[0].message.content

        # Upload the response to the specified S3 bucket
        s3_client = boto3.client('s3')
        try:
            s3_client.put_object(
                Bucket=s3bucket,
                Key=s3_key,
                Body=json.dumps({"response": response}),
                ContentType='application/json'
            )
        except ClientError as e:
            logging.error(f"Error uploading to S3: {str(e)}")
            raise

        return {"statusCode": 200, "body": json.dumps({"response": response})}
    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
