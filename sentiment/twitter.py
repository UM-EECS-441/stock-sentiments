from reddit import analyze_sentiment
import tweepy
import time
from datetime import date
from datetime import timedelta  
from datetime import timezone
import pytz
from datetime import datetime as dt, timedelta

import nltk
import random
from nltk.classify.scikitlearn import SklearnClassifier
import pickle
from sklearn.naive_bayes import MultinomialNB, BernoulliNB
from sklearn.linear_model import LogisticRegression, SGDClassifier
from sklearn.svm import SVC, LinearSVC, NuSVC
from nltk.classify import ClassifierI
from statistics import mode
from nltk.tokenize import word_tokenize
import re
import pandas as pd
import pickle
from nltk.corpus import stopwords
import os.path
from os import path
from sklearn.metrics import f1_score
from nltk.sentiment.vader import SentimentIntensityAnalyzer

from nltk.classify.scikitlearn import SklearnClassifier
from sklearn.svm import SVC

def twitter_func(LIMIT, text_query):
    consumer_key = "8MApPvLaGIhhpH2f9Rjo8UNSW"
    consumer_secret = "d4jQKY2NsoLtcAHOCz7BDQTkoCfsBNQgQkpbP5UmR5c3PGhgJQ"
    access_token = "1319774253672206337-TM212SolEHiZNe16ysemBb7I1U4zci"
    access_token_secret = "dcEMs4fQF13KO4MDuOSCWwLnpluip8alNtdgOFjQ2aPTd"


    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth,wait_on_rate_limit=True)

    # test authentication
    try:
        api.verify_credentials()
        print("Authentication OK")
    except:
        print("Error during authentication")
    # text_query = 'AAPL'


    try:
        # Creation of query method using parameters
        tweets = tweepy.Cursor(api.search,q=text_query, lang="en").items(LIMIT)
        # Pulling information from tweets iterable object
        tweets_list = [[tweet.created_at, tweet.text] for tweet in tweets]
        tweets_for_records = [[tweet.created_at, tweet.id, tweet.text] for tweet in tweets]
        
        # Creation of dataframe from tweets list
        # Add or remove columns as you remove tweet information
        tweets_df = pd.DataFrame(tweets_list, columns = ['time_created', 'text'])
        tweets_for_records = pd.DataFrame(tweets_for_records, columns = ['time_created', 'id', 'text'])
        tweets_for_records.to_csv('twitter.csv', index=False)
        
    except BaseException as e:
        print('failed on_status,',str(e))
        time.sleep(3)
    fifteen_min_ago = dt.now(tz=timezone.utc) - timedelta(minutes = 15)
    timestamp = dt.timestamp(fifteen_min_ago)
    tweets_df['timestamp'] = tweets_df.apply(lambda row: row.time_created.timestamp(), axis=1)
    past_fifteen_min = tweets_df['timestamp'] >= timestamp
    tweets_df = tweets_df[past_fifteen_min]

    del tweets_df['time_created']
    analyze_sentiment(tweets_df, "twitter_scores-" + text_query)
    return tweets_df

# LIMIT = 100
# twitter_func(LIMIT, 'AAPL')