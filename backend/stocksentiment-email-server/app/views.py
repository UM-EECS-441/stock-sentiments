from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json

import boto3
from botocore.exceptions import ClientError

SENDER = "StockSentiments <StockSentiment@umich.edu>"
CONFIGURATION_SET = "ConfigSet"
AWS_REGION = "us-east-1"

@csrf_exempt
def send_emails(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    emails = json_data['emails']
    stock = json_data['stock']
    score = json_data['score']

    SUBJECT = "Sentiment Alert"

    BODY_TEXT = ("The sentiment of " + stock + " has significantly changed and is now " + score + ".")

    BODY_HTML = """<html>
    <head></head>
    <body>
      <p>The sentiment of {stock} has significantly changed and is now {score}.</p>
      <p>We analyzed the latest Twitter and Reddit posts about {stock}, and classified each post as either positive (+1) or negative (-1) using our trained classification sentiment analysis model. The live sentiment score is the mean of the assigned binary labels.
    </body>
    </html>
    """.format(stock=stock, score=score)

    CHARSET = "UTF-8"

    client = boto3.client('ses',region_name=AWS_REGION)

    # Try to send the emails.
    response = {}
    for email in emails:
        try:
            #Provide the contents of the email.
            response = client.send_email(
                Destination={
                    'ToAddresses': [
                        email,
                    ],
                },
                Message={
                    'Body': {
                        'Html': {
                            'Charset': CHARSET,
                            'Data': BODY_HTML,
                        },
                        'Text': {
                            'Charset': CHARSET,
                            'Data': BODY_TEXT,
                        },
                    },
                    'Subject': {
                        'Charset': CHARSET,
                        'Data': SUBJECT,
                    },
                },
                Source=SENDER,
                # If you are not using a configuration set, comment or delete the
                # following line
                #ConfigurationSetName=CONFIGURATION_SET,
            )
        # Display an error if something goes wrong.
        except ClientError as e:
            response[email] = False
        else:
            response[email] = True

    return JsonResponse(response)


def test(request):
    if request.method != 'GET':
        return HttpResponse(status=200)
    response = {}
    response['test'] = 'works'
    return JsonResponse(response)

