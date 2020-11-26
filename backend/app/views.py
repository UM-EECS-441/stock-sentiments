from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection

from django.views.decorators.csrf import csrf_exempt
import json
import requests

from google.oauth2 import id_token
from google.auth.transport import requests as grequests

import hashlib, time

# Create your views here.

@csrf_exempt
def signin(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    clientID = json_data['clientID']   # the front end app's OAuth 2.0 Client ID
    idToken = json_data['idToken']     # user's OpenID ID Token, a JSon Web Token (JWT)

    currentTimeStamp = time.time()
    backendSecret = "hailhydra"

    try:
        # Collect user info from the Google idToken, verify_oauth2_token checks
        # the integrity of idToken and throws a "ValueError" if idToken or
        # clientID is corrupted or if user has been disconnected from Google
        # OAuth (requiring user to log back in to Google).
        idinfo = id_token.verify_oauth2_token(idToken, grequests.Request(), clientID)

        # Verify the token is valid and fresh
        if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
            raise ValueError('Wrong issuer.')
        if currentTimeStamp >= idinfo['exp']:
            raise ValueError('Expired token.')

    except ValueError:
        # Invalid or expired token
        return HttpResponse(status=511)  # 511 Network Authentication Required

    # Check if token already exists in database
    # Instead of the unlimited length ID Token,
    # we work with a fixed-size SHA256 of the ID Token.
    tokenhash = hashlib.sha256(idToken.strip().encode('utf-8')).hexdigest()

    cursor = connection.cursor()
    cursor.execute("SELECT userid FROM testusertable WHERE idtoken='"+ tokenhash +"';")

    userID = cursor.fetchone()
    if userID is not None:
        # if we've already seen the token, return associated userID
        return JsonResponse({'userID': userID[0]})

    # If it's a new token, get username
    try:
        username = idinfo['name']
    except:
        username = "Profile NA"

    # Compute chatterID and add to database
    hashable = idToken + username + str(currentTimeStamp) + backendSecret
    userID = hashlib.sha256(hashable.strip().encode('utf-8')).hexdigest()
    cursor.execute('INSERT INTO testusertable (userid, idtoken) VALUES '
                   '(%s, %s);', (userID, tokenhash))

    # Return chatterID
    return JsonResponse({'userID': userID})

def get_tickers(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    cursor = connection.cursor()
    cursor.execute('SELECT * FROM tickertable;')
    rows = cursor.fetchall()

    response['data'] = []

    for row in rows:
        datum = {}
        datum['symbol'] = row[1]
        datum['name'] = row[0]
        response['data'].append(datum)

    return JsonResponse(response)


def get_watchlist_score(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    uid = str(request.GET.get('uid'))
    response['uid'] = uid
    
    cursor = connection.cursor()
    cursor.execute('SELECT userid, ticker, realname, currsentiment, time FROM subscriptiontable S, tickertable T WHERE S.subscription = T.ticker')
    
    rows = cursor.fetchall()
    response['data'] = []
    for row in rows:
        if row[0].upper() == uid.upper():
            datum = {}
            datum['symbol'] = row[1]
            datum['name'] = row[2]
            datum['score'] = row[3]
            datum['timestamp'] = row[4]
            response['data'].append(datum)
    

    return JsonResponse(response)


def subscribe(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    
    ticker = str(request.GET.get('ticker'))
    uid = str(request.GET.get('uid'))


    response = {}
    response['uid'] = uid
    response['ticker'] = ticker
    
    cursor = connection.cursor()
    cursor.execute('SELECT userid, subscription FROM subscriptiontable s WHERE s.userid = %s AND s.subscription = %s', (uid, ticker,))
    rows = cursor.fetchall()
    
    if len(rows) != 0:
        return HttpResponse(status=500) #maybe change this later
    
    cursor = connection.cursor()
    cursor.execute('INSERT INTO subscriptiontable (userid, subscription) VALUES '
            '(%s, %s);', (uid, ticker))


    return JsonResponse(response)


def unsubscribe(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    
    ticker = str(request.GET.get('ticker'))
    uid = str(request.GET.get('uid'))

    response = {}

    response['ticker'] = ticker
    response['uid'] = uid

    cursor = connection.cursor()
    cursor.execute('SELECT userid, subscription FROM subscriptiontable s WHERE s.userid = %s AND s.subscription = %s', (uid, ticker,))
    rows = cursor.fetchall()

    if len(rows) == 0:
        return HttpResponse(status=500)

    cursor = connection.cursor()
    cursor.execute('DELETE FROM subscriptiontable WHERE userid = %s AND subscription = %s', (uid, ticker,))


    return JsonResponse(response)


def update_sentiment(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    ticker = str(request.GET.get('ticker'))
    score = float(request.GET.get('score'))

    response = {}
    response['ticker'] = ticker
    response['score'] = score

    
    cursor = connection.cursor()
    cursor.execute('SELECT realname, currsentiment FROM tickertable WHERE ticker = %s', (ticker,))
    row = cursor.fetchone()
    response['rows'] = row
    
    if row == None:
        return HttpResponse(status=500)
    
    old_score = row[1]
    if (abs(score - old_score) > 0.5):
        send_email(ticker, score)

    cursor = connection.cursor()
    cursor.execute('UPDATE tickertable SET currsentiment = %s, time = CURRENT_TIMESTAMP WHERE ticker = %s', (score, ticker,))


    return JsonResponse(response)


def send_email(ticker, score):
    #cursor = connection.cursor()
    #cusor.execute(FIND ALL EMAILS TO SEND TO)
    EC2_ENDPOINT = "http://ec2-174-129-79-166.compute-1.amazonaws.com/send_email/"

    payload = "{\r\n  \"email\": \"sentimentstock@gmail.com\",\r\n  \"stock\": \"" + ticker + "\",\r\n  \"score\": \"" + str(score) + "\"\r\n}"
    headers = {
        'Content-Type': 'text/plain'
    }

    response = requests.request("POST", url, headers=headers, data = payload)
    # check response
