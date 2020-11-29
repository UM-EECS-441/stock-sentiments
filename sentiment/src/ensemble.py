from twitter import twitter_func
from reddit import reddit_func
import os.path
from os import path
import pandas as pd
from datetime import datetime as dt
from datetime import timezone
import requests
import json
from django.db import connection

ensemble_funcs = [twitter_func, reddit_func]


def get_sentiment_score(LIMIT, ticker):
    ensemble = []
    for func in ensemble_funcs:
        df = func(LIMIT, ticker)
        ensemble.append(df)
    result = pd.concat(ensemble)
    sentiment_score = 0
    if len(result) > 0:
        average = result.mean(axis=0)
        sentiment_score = average['scores']
    return sentiment_score

def update_sentiment_scores(LIMIT, ticker_list):
    for ticker in ticker_list:
        sentiment_score = get_sentiment_score(LIMIT, ticker)
        request_url = "http://161.35.6.60/update_sentiment/?score={}&ticker={}".format(sentiment_score, ticker)
        response = requests.get(request_url)


def get_ticker_list():
    tickers = []
    request_url = "http://161.35.6.60/get_tickers"
    response = requests.get(request_url)
    tickers_response = json.loads(response.text)
    for entry in tickers_response["data"]:
        tickers.append(entry["symbol"])
    return tickers

def delete_old_sentiment_ensemble():
    request_url = "http://161.35.6.60/delete_old_sentiment/"
    response = requests.get(request_url)
    return response
    

ticker_list = get_ticker_list()
update_sentiment_scores(100, ticker_list)
delete_func = delete_old_sentiment_ensemble()


