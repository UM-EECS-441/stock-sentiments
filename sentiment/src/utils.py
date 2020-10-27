import nltk
from nltk.classify.scikitlearn import SklearnClassifier
from nltk.classify import ClassifierI
from nltk.tokenize import word_tokenize
from sklearn.linear_model import LogisticRegression, SGDClassifier
from nltk.classify.scikitlearn import SklearnClassifier
import pickle


def find_features(document, word_features):
    words = word_tokenize(document)
    features = {}
    for w in word_features:
        features[w] = (w in words)
    return features


def analyze_sentiment(df):
    word_features = pickle.load( open( "../models/word_features.pkl", "rb" ) )
    classifier = pickle.load( open( "../models/logreg.model", "rb" ) )

    sentiment_scores = []
    for i in range(len(df.index)):
        comment = df['text'].iloc[i]
        sentiment_score = classifier.classify(find_features(comment, word_features))
        sentiment_scores.append(sentiment_score)
        # print(comment, ": ", sentiment_score)
    df["scores"] = sentiment_scores

    return df