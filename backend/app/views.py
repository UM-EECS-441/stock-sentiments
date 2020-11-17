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
    cursor.execute("SELECT userid FROM testUserTable WHERE idtoken='"+ tokenhash +"';")

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
    cursor.execute('INSERT INTO testUserTable (userid, idtoken) VALUES '
                   '(%s, %s);', (userID, tokenhash))

    # Return chatterID
    return JsonResponse({'userID': userID})

def get_tickers(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    cursor = connection.cursor()
    cursor.execute('SELECT subscription, COUNT(*) from subscriptiontable group by subscription')
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


def continue_no_sign_in(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    deviceid = str(request.GET.get('deviceid'))
    #query by deviceid
    cursor = connection.cursor()
    cursor.execute('select userid from usertable1 where deviceid = %s;', (deviceid,))
    row = cursor.fetchone()
    # if not already in continue without signing in table -->
    # insert into ids table which makes sure no overlapping id
    # and then insert into continue without signing in table and returning uid and deviceid
    if row is None:
        cursor.execute('insert into ids values (null);')
        cursor.execute('select * from ids ORDER BY userid desc;')
        row = cursor.fetchone()

        cursor.execute('insert into usertable1 values (%s, %s);' (deviceid, row[1],))
    else:
       pass #else they already have a userid so we can straight return it to the front end


    response['data'] = []

    datum = {}
    datum['uid'] = row[1]
    datum['deviceid'] = deviceid
    response['data'].append(datum)

    return JsonResponse(response)


def login(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    deviceid = str(request.GET.get('deviceid'))
    email = str(request.GET.get('email'))
    password = str(request.GET.get('password'))

    cursor = connection.cursor()
    cursor.execute('select * from usertable2 where deviceid = %s AND email = %s;', (deviceid, email,))
    row = cursor.fetchone()
    # if doesn't exist reject
    if row is None:
        return HttpResponse(status=403) #forbidden? Need a different code
    else:
        if password != row[2]:
            return HttpResponse(status=403) #bad password? Needs to be handled differently
      
     
    response['data'] = []

    datum = {}
    datum['uid'] = row[1]
    datum['email'] = email
    datum['deviceid'] = deviceid
    datum['password'] = password
    response['data'].append(datum)

    return JsonResponse(response)

def signup(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}

    # Get incoming information
    deviceid = str(request.GET.get('deviceid'))
    email = str(request.GET.get('email'))
    password = str(request.GET.get('password'))
    
    #select from usertable2
    cursor = connection.cursor()
    cursor.execute('SELECT userid from usertable2 WHERE email = %s;', (email,))

    row = cursor.fetchone()
    if row is not None: #IF THERE IS ALREADY AN EMAIL IN THE TABLE --> NO ACCOUNT CREATION ALLOWED
        return httpResponse(status=403)
    else: #if incoming password is not equal to the selected row return a bad status
        cursor.execute('insert into ids values (null);')
        cursor.execute('select * from ids ORDER BY userid desc;')
        row = cursor.fetchone()
        #insert a new account
        cursor.execute('INSERT INTO usertable2 VALUES (%s, %s, %s, %s);', (email, deviceid, password, row[1],))


    response['data'] = []
    
    #return uid
    datum = {}
    datum['uid'] = row[1]
    datum['email'] = email
    datum['deviceid'] = deviceid
    datum['password'] = password
    response['data'].append(datum)

    return JsonResponse(response)


def get_watchlist_score(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    uid = int(request.GET.get('uid'))
    response['userid'] = uid
    
    cursor = connection.cursor()
    cursor.execute('SELECT userid, T.ticker, T.realname, T.currsentiment, T.time, b.tweets, r.posts FROM subscriptiontable S, tickertable T, tweettable b, reddittable r WHERE S.subscription = T.ticker AND S.userid = %s AND T.ticker = b.ticker AND r.ticker = T.ticker;', (uid,))
    
    rows = cursor.fetchall()
    response['data'] = []
    temp_list = {}
    for row in rows:
        if row[0] == uid:
            datum = {}
            datum['symbol'] = row[1]
            datum['name'] = row[2]
            datum['score'] = row[3]
            datum['timestamp'] = row[4]
            datum['posts'] = []
            for tweets in row[5]:
                temp_list = {}
                temp_list['source'] = 'Twitter'
                temp_list['text'] = tweets
                temp_list['time'] = row[4] #We can't get actual tweet time --> So we take time of insertion
                datum['posts'].append(temp_list)
            #Only adding tweets right now, reddit isn't implemented

            response['data'].append(datum)
            temp_list = {}
   

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
    if (abs(score - old_score) > 0.5):
        try:
            send_email(ticker, score)
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

def delete_old_sentiment(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    sqlstring = '\'1 days\''
    cursor = connection.cursor()
    cursor.execute('DELETE FROM sentimenttable where time < now() - interval %s;', (sqlstring,))
    response = {}
    return JsonResponse(response)
