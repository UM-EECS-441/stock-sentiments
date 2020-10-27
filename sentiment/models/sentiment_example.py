
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

from nltk.classify.scikitlearn import SklearnClassifier
from sklearn.naive_bayes import MultinomialNB,BernoulliNB
from sklearn.linear_model import LogisticRegression,SGDClassifier
from sklearn.svm import SVC
from nltk.sentiment.vader import SentimentIntensityAnalyzer

sentence = "I have started to love Google, I'm gonna short Apple!"

#our_model
word_features = pickle.load( open( "word_features.pkl", "rb" ) )
classifier = pickle.load( open( "logreg.model", "rb" ) )
def find_features(document):
    words = word_tokenize(document)
    features = {}
    for w in word_features:
        features[w] = (w in words)
    return features
print("LogReg:", classifier.classify(find_features(sentence)))

#vader
sid = SentimentIntensityAnalyzer()
scores = sid.polarity_scores(sentence)
print("Vader:", scores['compound'])