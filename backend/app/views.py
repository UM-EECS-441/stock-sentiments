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
def sign_in(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    clientID = json_data['clientID']   # the front end app's OAuth 2.0 Client ID
    idToken = json_data['idToken']     # user's OpenID ID Token, a JSon Web Token (JWT)
    userEmail = json_data['email']     # user's google email

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
    # Temp: using email as unique identifier becaues idtoken seems to change
    # cursor.execute("SELECT userid FROM users WHERE idtoken='"+ tokenhash +"';")
    cursor.execute("SELECT userid, notifications FROM users WHERE email='"+ userEmail +"';")

    row = cursor.fetchone()
    if row is not None:
        # if we've already seen the token, return associated userID
        return JsonResponse({'userID': row[0], 'notifications': row[1]})

    # Compute userID and add to database
    hashable = idToken + str(currentTimeStamp) + backendSecret
    userID = hashlib.sha256(hashable.strip().encode('utf-8')).hexdigest()
    notifications = False
    cursor.execute('INSERT INTO users (userid, idtoken, email, notifications) VALUES '
                   '(%s, %s, %s, %s);', (userID, tokenhash, userEmail, notifications,))

    # Return userID
    return JsonResponse({'userID': userID, 'notifications': notifications})

def no_sign_in(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    # Using deviceid string as userid
    userID = str(request.GET.get('deviceID'))
    cursor = connection.cursor()
    cursor.execute('SELECT userid FROM users WHERE userid = %s;', (userID,))
    row = cursor.fetchone()

    if row is None:
        cursor.execute('INSERT INTO users (userid, notifications) VALUES (%s, %s);', (userID, False))

    # Return userID
    return JsonResponse({'userID': userID})

@csrf_exempt
def toggle_notifications(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    userID = json_data['userID']                    # String unique id of user
    str_notifications = json_data['notifications']  # String True or False if user sets notifications
    notifications = False
    if str_notifications == 'true':
        notifications = True
    elif str_notifications != 'false':
        return HttpResponse(status=400)

    cursor = connection.cursor()

    # Check if this account has an email (signed in user)
    cursor.execute('SELECT email FROM users WHERE userid = %s;', (userID,))
    email = cursor.fetchall()
    if email is None:
        return HttpResponse(status=400)
    email = email[0]
    if email is None:
        return HttpResponse(status=403)

    # Set user notification settings to the notifications specified
    cursor.execute('UPDATE users SET notifications = %s WHERE userid = %s;', (notifications, userID,))

    # Return only 200
    return HttpResponse(status=200)

def get_tickers(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    cursor = connection.cursor()
    cursor.execute('SELECT ticker, COUNT(*) from subscriptions group by ticker')
    rows = cursor.fetchall()

    ticker_count = {}
    for row in rows:
        ticker_count[str(row[0])] = str(row[1])

    #response['counts'] = ticker_count

    cursor = connection.cursor()
    cursor.execute('SELECT * FROM tickertable;')
    rows = cursor.fetchall()

    response['data'] =  []

    for row in rows:
        datum = {}
        datum['symbol'] = row[1]
        datum['name'] = row[0]
        if datum['symbol'] in ticker_count:
            datum['count'] = int(ticker_count[datum['symbol']])
        else:
            datum['count'] = 0
        response['data'].append(datum)

    return JsonResponse(response)

def get_watchlist_score(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    userID = str(request.GET.get('userID'))
    response['userID'] = userID
    
    cursor = connection.cursor()
    cursor.execute('SELECT userid, T.ticker, T.realname, T.currsentiment, T.time, b.tweets, r.posts FROM subscriptions S, tickertable T, tweettable b, reddittable r WHERE S.ticker = T.ticker AND S.userid = %s AND T.ticker = b.ticker AND r.ticker = T.ticker;', (userID,))
    
    rows = cursor.fetchall()
    response['data'] = []

    for row in rows:
        datum = {}
        datum['symbol'] = row[1]
        datum['name'] = row[2]
        datum['score'] = row[3]
        datum['timestamp'] = row[4]
        datum['posts'] = []
        # Only adding tweets right now, reddit isn't implemented
        for tweets in row[5]:
            temp_list = {}
            temp_list['source'] = 'Twitter'
            temp_list['text'] = tweets
            temp_list['time'] = row[4] # We can't get actual tweet time --> So we take time of insertion
            datum['posts'].append(temp_list)

        response['data'].append(datum)

    return JsonResponse(response)

def subscribe(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    
    ticker = str(request.GET.get('ticker'))
    userID = str(request.GET.get('userID'))
    
    cursor = connection.cursor()
    cursor.execute('SELECT userid, ticker FROM subscriptions WHERE userid = %s AND ticker = %s', (userID, ticker,))
    rows = cursor.fetchall()
    
    if len(rows) != 0:
        return HttpResponse(status=500)
    
    cursor = connection.cursor()
    cursor.execute('INSERT INTO subscriptions (userid, ticker) VALUES '
            '(%s, %s);', (userID, ticker))


    return HttpResponse(status=200)


def unsubscribe(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    
    ticker = str(request.GET.get('ticker'))
    userID = str(request.GET.get('userID'))

    cursor = connection.cursor()
    cursor.execute('SELECT userid, ticker FROM subscriptions WHERE userid = %s AND ticker = %s', (userID, ticker,))
    rows = cursor.fetchall()

    if len(rows) == 0:
        return HttpResponse(status=500)

    cursor = connection.cursor()
    cursor.execute('DELETE FROM subscriptions WHERE userid = %s AND ticker = %s', (userID, ticker,))

    return HttpResponse(status=200)


def update_sentiment(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    ticker = str(request.GET.get('ticker'))
    score = float(request.GET.get('score'))

    response = {}
    response['ticker'] = ticker
    response['score'] = score

    cursor = connection.cursor()

    # check if ticker name is valid
    cursor.execute('SELECT realname, currsentiment FROM tickertable WHERE ticker = %s;', (ticker,))
    row = cursor.fetchone()
    if row == None:
        return HttpResponse(status=500)

    # update ticker name
    response['rows'] = row
    cursor.execute('UPDATE tickertable SET currsentiment = %s, time = CURRENT_TIMESTAMP WHERE ticker = %s;', (score, ticker,))

    # update sentimenttable with sentiment score and current stock price
    finnhub_token = 'buve6of48v6vrjlugeh0'
    request_url = 'https://finnhub.io/api/v1/quote?symbol={}&token={}'.format(ticker, finnhub_token)
    r = requests.get(request_url)
    if r.status_code == 200:
        json_dict = r.json()
        cursor.execute('INSERT INTO sentimenttable VALUES (%s, %s, NOW(), %s);', (ticker, score, float(json_dict['c']),))

    # send email if significant change in sentiment
    old_score = row[1]
    if (abs(score - old_score) >= 1.0):
        try:
            send_emails(ticker, score)
        except:
            pass

    return JsonResponse(response)

def get_sentiment_score(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    ticker = str(request.GET.get('ticker'))
    response['ticker'] = ticker

    cursor = connection.cursor()
    cursor.execute('SELECT ticker, sentiment, time, price FROM sentimenttable WHERE ticker = %s order by time desc;', (ticker,))
    rows = cursor.fetchall()
    response['data'] = []
    for row in rows:
        if row[0].upper() == ticker.upper():
            datum = {}
            datum['ticker'] = row[0]
            datum['sentiment'] = row[1]
            datum['time'] = row[2]
            datum['price'] = row[3]
            response['data'].append(datum)
    return JsonResponse(response)

def send_emails(ticker, score):
    EC2_ENDPOINT = "http://ec2-174-129-79-166.compute-1.amazonaws.com/send_emails/"

    # Find all users' emails subscribed to this stock
    cursor = connection.cursor()
    cursor.execute('SELECT email, notifications FROM users u LEFT JOIN subscriptions s ON u.userid = s.userid WHERE s.ticker = %s;', (ticker,))
    rows = cursor.fetchall()

    if rows == None:
        return

    # For testing purposes adding email we can all access
    emails = ['sentimentstock@gmail.com']
    for row in rows:
        if row[0] is not None:
            if row[1] == True:
                emails.append(row[0])

    payload = "{\r\n  \"emails\": " + str(emails) + ",\r\n  \"stock\": \"" + ticker + "\",\r\n  \"score\": \"" + str(score) + "\"\r\n}"
    payload = payload.replace("'", '"')
    headers = {
        'Content-Type': 'application/json'
    }

    response = requests.request("POST", EC2_ENDPOINT, headers=headers, data=payload)
    # check response

def delete_old_sentiment(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    sqlstring = '\'1 days\''
    cursor = connection.cursor()
    cursor.execute('DELETE FROM sentimenttable where time < now() - interval %s;', (sqlstring,))
    response = {}
    return JsonResponse(response)
