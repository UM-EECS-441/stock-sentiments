from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection

from django.views.decorators.csrf import csrf_exempt
import json
import requests

# Create your views here.

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
