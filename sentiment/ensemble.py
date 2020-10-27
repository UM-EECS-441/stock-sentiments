from twitter import twitter_func
from reddit import reddit_func
import os.path
from os import path
import pandas as pd
from datetime import datetime as dt
from datetime import timezone


def ensemble_query(LIMIT, text_query):
    tweets_df = twitter_func(LIMIT, text_query)
    reddit_df = reddit_func(LIMIT, text_query)
    ensemble = [tweets_df, reddit_df]
    result = pd.concat(ensemble)
    result.to_csv('ensemble-' + text_query + '.csv', index=False)
    average = result.mean(axis=0)
    print("Our Ensemble score: ", average['our_model'])
    print("VADER's Ensemble score: ", average['vader'])
    return (average['our_model'], average['vader'])


def ensemble_aggregate(LIMIT, text_queries):
    for query in text_queries:
        (our_model, vader) = ensemble_query(LIMIT, query)
        ensemble_df = None
        right_now = dt.now(tz=timezone.utc)
        right_now = dt.timestamp(right_now)
        entry = [[right_now, query, our_model, vader]]
        result = pd.DataFrame(entry, columns = ['time', 'query', 'our_model', 'vader'])
        #TODO push into db with stock data for tickers 
        if (path.exists("aggregate-" + query + ".csv") == True):
            ensemble_df = pd.read_csv("aggregate-" + query + ".csv")
            result = [ensemble_df, result]
            result = pd.concat(result)
        result.to_csv('aggregate-' + query + '.csv', index=False)

# TODO: fetch list of stocks from database to pass as parameter below
ensemble_aggregate(100, ['TESLA', 'AAPL', 'UBER', 'MSFT', 'AMZN'])