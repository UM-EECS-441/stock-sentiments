from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
import json

import boto3
from botocore.exceptions import ClientError

SENDER = "StockSentiments <StockSentiment@umich.edu>"
CONFIGURATION_SET = "ConfigSet"
AWS_REGION = "us-east-1"

@csrf_exempt
def send_email(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    email = json_data['email']
    stock = json_data['stock']
    score = json_data['score']
    #percent_change = json_data['percent_change']
    #posts

    SUBJECT = "Sentiment Alert"

    BODY_TEXT = ("The sentiment of " + stock + " has significantly changed and is now " + score + ".")

    BODY_HTML = """<html>
    <head></head>
    <body>
      <p>The sentiment of {stock} has significantly changed and is now {score}.</p>
    </body>
    </html>
    """.format(stock=stock, score=score)

    CHARSET = "UTF-8"

    client = boto3.client('ses',region_name=AWS_REGION)

    # Try to send the email.
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
        return HttpResponse(status=500)
    else:
        return JsonResponse({})


def test(request):
    if request.method != 'GET':
        return HttpResponse(status=200)
    response = {}
    response['test'] = 'works'
    return JsonResponse(response)

