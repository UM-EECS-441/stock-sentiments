from twitter import twitter_func
from reddit import reddit_func
import pandas as pd
def ensemble_query(LIMIT, text_query):
    tweets_df = twitter_func(LIMIT, text_query)
    reddit_df = reddit_func(LIMIT, text_query)
    ensemble = [tweets_df, reddit_df]
    result = pd.concat(ensemble)
    result.to_csv('ensemble.csv', index=False)
    average = result.mean(axis =0)
    print("Our Ensemble score: ", average['our_model'])
    print("VADER's Ensemble score: ", average['vader'])
    return result

ensemble_query(100, 'TESLA')
    