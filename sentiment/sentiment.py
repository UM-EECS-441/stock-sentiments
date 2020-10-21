
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
stop_words = list(set(stopwords.words('english')))
files = pd.read_csv("stock_data.csv")
all_words = []
documents = []
allowed_word_types = ["J", "V"]
if(path.exists("documents.pkl") == False):
    for i in range (0,int(files.size/2)) :
        pair = (files['Text'].iloc[i], files['Sentiment'].iloc[i])
        documents.append(pair)
        cleaned = re.sub(r'[^(a-zA-Z)\s]','', pair[0])
        #tokenize
        tokenized = word_tokenize(cleaned)
        # remove stopwords 
        stopped = [w for w in tokenized if not w in stop_words]
        
        # parts of speech tagging for each word 
        pos = nltk.pos_tag(stopped)
        
        # make a list of  all adjectives identified by the allowed word types list above
        for w in pos:
            if w[1][0] in allowed_word_types:
                all_words.append(w[0].lower())


        
    pickle.dump(documents, open("documents.pkl", "wb"))
    pickle.dump(all_words, open("all_words.pkl", "wb"))
else:
    documents = pickle.load( open( "documents.pkl", "rb" ) )
    all_words = pickle.load( open("all_words.pkl", "rb"))

# creating a frequency distribution of each adjectives.


all_words = nltk.FreqDist(all_words)

# listing the 5000 most frequent words
word_features = list(all_words.keys())[:5000]

# function to create a dictionary of features for each review in the list document.
# The keys are the words in word_features 
# The values of each key are either true or false for wether that feature appears in the review or not

def find_features(document):
    words = word_tokenize(document)
    features = {}
    for w in word_features:
        features[w] = (w in words)
    return features

# Creating features for each review
featuresets = [(find_features(rev), category) for (rev, category) in documents]

# Shuffling the documents 
random.shuffle(featuresets)
print(int(.8*len(featuresets)))
train_split = int(.8*len(featuresets))

training_set = featuresets[:train_split]
testing_set = featuresets[train_split:]

classifier = nltk.NaiveBayesClassifier.train(training_set)

print("Classifier accuracy percent:",(nltk.classify.accuracy(classifier, testing_set))*100)

classifier.show_most_informative_features(15) 
preds = []
actuals = []
# print(testing_set[0])
for i in testing_set:
    preds.append(classifier.classify(i[0]))
    actuals.append(i[1])
from sklearn.metrics import f1_score
print(f1_score(actuals, preds, labels = [-1, 1], average = 'micro'))


