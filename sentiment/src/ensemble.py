from twitter import twitter_func
from reddit import reddit_func
import os.path
from os import path
import pandas as pd
from datetime import datetime as dt
from datetime import timezone

from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection

from django.views.decorators.csrf import csrf_exempt
import json

ensemble_funcs = [twitter_func, reddit_func]

def ensemble_query(LIMIT, text_query):
    ensemble = []
    for func in ensemble_funcs:
        df = func(LIMIT, text_query)
        ensemble.append(df)
    result = pd.concat(ensemble)
    average = result.mean(axis=0)
    return (average['scores'])


def ensemble_aggregate(LIMIT, text_queries):
    for query in text_queries:
        (scores) = ensemble_query(LIMIT, query)
        ensemble_df = None
        right_now = dt.now(tz=timezone.utc)
        right_now = dt.timestamp(right_now)
        entry = [[right_now, query, scores]]
        result = pd.DataFrame(entry, columns = ['time', 'query', 'scores'])
        # TODO: push to db with tickers
        if(path.exists("aggregate-" + query + ".csv") == True):
            ensemble_df = pd.read_csv("aggregate-" + query + ".csv")
            result = [ensemble_df, result]
            result = pd.concat(result)
        
        result.to_csv('aggregate-' + query + '.csv', index=False)


# TODO: fetch list of tickers from database
tickers = []

cursor = connection.cursor()
cursor.execute('SELECT ticker FROM tickertable;')
rows = cursor.fetchall()
for row in rows:
    tickers.append(row[1])
print(tickers)

# ensemble_aggregate(100, tickers )