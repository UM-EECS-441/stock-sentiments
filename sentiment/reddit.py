import praw

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

LIMIT = 200

reddit = praw.Reddit(client_id='GDOKPrBB4GK8CA', client_secret='h0duFt5U7GqKmjNXFe2CL45JJZ0', user_agent='StockSentiment')
all_posts = reddit.subreddit('all')
posts = []
for post in all_posts.search('Tesla', sort='top', time_filter = 'hour', limit=LIMIT):
    # print(post.title, post.subreddit, post.url, post.created)
    posts.append([post.title, post.selftext, post.subreddit, post.url, post.created])
posts = pd.DataFrame(posts, columns=['comment', 'body', 'subreddit', 'url', 'created'])
# print(posts)
posts.to_csv('reddit.csv', index=False) 

word_features = pickle.load( open( "word_features.pkl", "rb" ) )
classifier = pickle.load( open( "logreg.model", "rb" ) )
def find_features(document):
    words = word_tokenize(document)
    features = {}
    for w in word_features:
        features[w] = (w in words)
    return features
overall_sentiment = []
our_sum = 0
vader_sum = 0
sid = SentimentIntensityAnalyzer()
for i in range(0,int(posts.size/5)):
    comment = posts['comment'].iloc[i]
    sentiment = classifier.classify(find_features(comment))
    scores = sid.polarity_scores(comment)
    score = scores['compound']
    our_sum = our_sum + (sentiment)
    vader_sum = vader_sum + score
    overall_sentiment.append([comment, sentiment, score])
    # print(sentiment)

post_sentiment = pd.DataFrame(overall_sentiment, columns=['comment', 'our_model', 'vader'] )
post_sentiment.to_csv('sentiment_reddit.csv', index=False)
print("Our Model's avg score: ", our_sum/LIMIT)
print("VADER's avg score: ", vader_sum/LIMIT)