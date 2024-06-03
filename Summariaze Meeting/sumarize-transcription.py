import boto3
import json
import os
import logging
from openai import OpenAI

# Configure logging to display INFO level messages
logging.basicConfig(level=logging.INFO)


def lambda_handler(event, context):
    """
    AWS Lambda function handler. This function is triggered by an S3 event.
    It downloads a JSON file from S3, processes the content, and uploads a summary to S3.

    Args:
        event (dict): Event data passed by the trigger (S3 event in this case).
        context (object): Runtime information provided by AWS Lambda.
    """
    print(json.dumps(event))

    try:
        # Log the incoming event for debugging purposes
        logging.info("Received event: %s", json.dumps(event))

        # Extract S3 bucket and object key from the event
        record = event['Records'][0]
        s3bucket = record['s3']['bucket']['name']
        s3object = record['s3']['object']['key']

        # Initialize S3 client
        s3_client = boto3.client('s3')

        # Temporary file path for downloaded JSON file
        temp_file = '/tmp/tempfile.json'
        try:
            # Download the file from S3 to the temporary file path
            s3_client.download_file(s3bucket, s3object, temp_file)
        except ClientError as e:
            logging.error(f"Error downloading file from S3: {str(e)}")
            raise

        # Read the content of the downloaded JSON file
        with open(temp_file, 'r') as file:
            file_content = json.load(file)

        # Extract transcripts from the results key
        transcripts_list = file_content.get(
            'results', {}).get('transcripts', '')
        if not transcripts_list:
            raise ValueError("Transcripts not found in the JSON file.")

        transcript = transcripts_list[0].get('transcript', '')
        if not transcript:
            raise ValueError("Transcript text not found in the JSON file.")

        # Prepare file name by removing extension and path
        file_name = s3object.split('/')[-1]
        meeting_name = file_name.replace('.mp3-transcript.json', '')

        # Define the S3 key for the summary output
        outputKey = f'summary/{meeting_name}-summary.json'

        # Retrieve the OpenAI API key from environment variables
        api_key = os.getenv('OPENAI_API_KEY')
        if not api_key:
            raise ValueError("OpenAI API key not found.")

        # Initialize OpenAI client with the API key
        client = OpenAI(api_key=api_key)

        # Prepare messages for the OpenAI API call
        messages = [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": f"Summarize the following transcript giving bullet points: {transcript}"}
        ]

        # Call OpenAI API to create a summary
        completion = client.chat.completions.create(
            model="gpt-4", messages=messages, max_tokens=250)
        response = completion.choices[0].message.content

        # Upload the summary response to the specified S3 bucket
        try:
            s3_client.put_object(
                Bucket=s3bucket,
                Key=outputKey,
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
