import boto3
import uuid
import json


def lambda_handler(event, context):

    print(json.dumps(event))

    record = event['Records'][0]

    s3bucket = record['s3']['bucket']['name']
    s3object = record['s3']['object']['key']

    s3Path = f's3://{s3bucket}/{s3object}'
    jobName = f'{s3object}--{str(uuid.uuid4())}'
    outputKey = f'transcripts/{s3object}-transcript.json'

    client = boto3.client('transcribe')

    response = client.start_transcription_job(
        TranscriptionJobName=jobName,
        LanguageCode='en-US',
        Media={'MediaFileUri': s3Path},
        OutputBucketName=s3bucket,
        OutputKey=outputKey
    )

    print(json.dumps(response, default=str))

    return {
        'TranscriptionJobName': response['TranscriptionJob']['TranscriptionJobName']
    }


# V2

# s3 = boto3.client('s3')
# transcribe = boto3.client('transcribe')


# def lambda_handler(event, context):
#     # Get the S3 bucket and object key from the event
#     bucket = event['Records'][0]['s3']['bucket']['name']
#     key = urllib.parse.unquote_plus(
#         event['Records'][0]['s3']['object']['key'], encoding='utf-8')

#     # Generate a unique job name using the key
#     job_name = key.replace('/', '_')

#     # Create the S3 object URI
#     s3_uri = f's3://{bucket}/{key}'

#     # Start transcription job
#     response = transcribe.start_transcription_job(
#         TranscriptionJobName=job_name,
#         Media={'MediaFileUri': s3_uri},
#         MediaFormat=key.split('.')[-1],
#         LanguageCode='en-US',
#         OutputBucketName='<DESTINATION_BUCKET_NAME>',
#         OutputKey=f'transcriptions/{job_name}.json'
#     )

#     return {
#         'statusCode': 200,
#         'body': json.dumps('Transcription job started successfully')
#     }
