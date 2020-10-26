import praw
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


def find_features(document, word_features):
    words = word_tokenize(document)
    features = {}
    for w in word_features:
        features[w] = (w in words)
    return features
def analyze_sentiment(df, filename):
    word_features = pickle.load( open( "word_features.pkl", "rb" ) )
    classifier = pickle.load( open( "logreg.model", "rb" ) )

    our_calcs = []
    vader_calcs =[]
    total = 0
    sid = SentimentIntensityAnalyzer()
    for i in range(0,int(df.size/2)):
        total= total+1 
        comment = df['text'].iloc[i]
        sentiment = classifier.classify(find_features(comment, word_features))
        scores = sid.polarity_scores(comment)
        score = scores['compound']
        our_calcs.append(sentiment)
        vader_calcs.append(score)

    df["our_model"] = our_calcs
    df["vader"] = vader_calcs
    df.to_csv(filename + '.csv', index=False)
    print("Our Model's avg score: ", sum(our_calcs)/(total))
    print("VADER's avg score: ", sum(vader_calcs)/total)

def reddit_func(LIMIT, text_query):
    reddit = praw.Reddit(client_id='GDOKPrBB4GK8CA', client_secret='h0duFt5U7GqKmjNXFe2CL45JJZ0', user_agent='StockSentiment')
    all_posts = reddit.subreddit('all')
    posts = []
    posts_for_records = []

    for post in all_posts.search(text_query, sort='top', time_filter = 'hour', limit=LIMIT):
        # print(post.title, post.selftext, post.subreddit, post.url, post.created)
        posts_for_records.append([post.title, post.selftext, post.subreddit, post.url, post.created])
        posts.append([post.title, post.created])

    posts = pd.DataFrame(posts, columns=['text', 'timestamp'])
    posts_for_records = pd.DataFrame(posts_for_records, columns=['text', 'body', 'subreddit', 'url', 'timestamp'])
    posts_for_records.to_csv('reddit.csv', index=False) 
    fifteen_min_ago = dt.now(tz=timezone.utc) - timedelta(minutes = 15)
    timestamp = dt.timestamp(fifteen_min_ago)
    past_fifteen_min = posts['timestamp'] >= timestamp
    posts = posts[past_fifteen_min]
    
    analyze_sentiment(posts, "reddit_scores")
    return posts


# LIMIT = 100
# reddit_func(LIMIT, 'AAPL')


