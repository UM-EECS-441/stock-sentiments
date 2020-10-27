from utils import analyze_sentiment
import tweepy
from datetime import date, timedelta, timezone, datetime as dt
import pandas as pd


def twitter_func(LIMIT, text_query):
    # set up Twitter API 
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

    try:
        # Creation of query method using parameters
        tweets = tweepy.Cursor(api.search,q=text_query, lang="en").items(LIMIT)

        # Pulling information from tweets iterable object
        tweets_list = [[tweet.created_at, tweet.text] for tweet in tweets]
        
        # Creation of dataframe from tweets list
        tweets_df = pd.DataFrame(tweets_list, columns = ['time_created', 'text'])
        
    except BaseException as e:
        print('failed on_status,',str(e))
        time.sleep(3)

    # filter posts for the last 15 min
    fifteen_min_ago = dt.now(tz=timezone.utc) - timedelta(minutes = 15)
    timestamp = dt.timestamp(fifteen_min_ago)
    tweets_df['timestamp'] = tweets_df.apply(lambda row: row.time_created.timestamp(), axis=1)
    past_fifteen_min = tweets_df['timestamp'] >= timestamp
    tweets_df = tweets_df[past_fifteen_min]
    del tweets_df['time_created']

    #add column for sentiment scores
    tweets_df = analyze_sentiment(tweets_df)
    return tweets_df
