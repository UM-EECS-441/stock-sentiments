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


consumer_key = "8MApPvLaGIhhpH2f9Rjo8UNSW"
consumer_secret = "d4jQKY2NsoLtcAHOCz7BDQTkoCfsBNQgQkpbP5UmR5c3PGhgJQ"
access_token = "1319774253672206337-TM212SolEHiZNe16ysemBb7I1U4zci"
access_token_secret = "dcEMs4fQF13KO4MDuOSCWwLnpluip8alNtdgOFjQ2aPTd"


auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth,wait_on_rate_limit=True)

text_query = 'AAPL'
LIMIT = 100

try:
 # Creation of query method using parameters
 tweets = tweepy.Cursor(api.search,q=text_query).items(LIMIT)
 
 # Pulling information from tweets iterable object
 tweets_list = [[tweet.created_at, tweet.id, tweet.text] for tweet in tweets]
 
 # Creation of dataframe from tweets list
 # Add or remove columns as you remove tweet information
 tweets_df = pd.DataFrame(tweets_list, columns = ['time_created', 'id', 'text'])
 
except BaseException as e:
    print('failed on_status,',str(e))
    time.sleep(3)
fifteen_min_ago = dt.now(tz=timezone.utc) - timedelta(minutes = 15)
timestamp = dt.timestamp(fifteen_min_ago)
tweets_df['timestamp'] = tweets_df.apply(lambda row: row.time_created.timestamp(), axis=1)
past_fifteen_min = tweets_df['timestamp'] >= timestamp
tweets_df = tweets_df[past_fifteen_min]

tweets_df.to_csv('twitter.csv', index=False) 

word_features = pickle.load( open( "word_features.pkl", "rb" ) )
classifier = pickle.load( open( "logreg.model", "rb" ) )
def find_features(document):
    words = word_tokenize(document)
    features = {}
    for w in word_features:
        features[w] = (w in words)
    return features
our_sum = 0
vader_sum = 0
our_calcs=[]
vader_calcs=[]
sid = SentimentIntensityAnalyzer()
for i in range(0,int(tweets_df.size/4)):
    comment = tweets_df['text'].iloc[i]
    sentiment = classifier.classify(find_features(comment))
    scores = sid.polarity_scores(comment)
    score = scores['compound']
    our_sum = our_sum + (sentiment)
    vader_sum = vader_sum + score
    our_calcs.append(sentiment)
    vader_calcs.append(score)

tweets_df['our_model'] = our_calcs
tweets_df['vader'] = vader_calcs


tweets_df.to_csv('twitter.csv', index=False) 

print("Our Model's avg score: ", our_sum/LIMIT)
print("VADER's avg score: ", vader_sum/LIMIT)