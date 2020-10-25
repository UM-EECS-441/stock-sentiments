import tweepy
import pandas as pd
import time
from datetime import date
from datetime import timedelta  
from datetime import timezone
import pytz
from datetime import datetime as dt, timedelta

consumer_key = "8MApPvLaGIhhpH2f9Rjo8UNSW"
consumer_secret = "d4jQKY2NsoLtcAHOCz7BDQTkoCfsBNQgQkpbP5UmR5c3PGhgJQ"
access_token = "1319774253672206337-TM212SolEHiZNe16ysemBb7I1U4zci"
access_token_secret = "dcEMs4fQF13KO4MDuOSCWwLnpluip8alNtdgOFjQ2aPTd"


auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth,wait_on_rate_limit=True)

text_query = 'AAPL'
count = 100
fifteen_min_ago = dt.now(tz=timezone.utc) - timedelta(minutes = 15)
timestamp = dt.timestamp(fifteen_min_ago)
today= date.today()
print("Today's date:", today)
try:
 # Creation of query method using parameters
 tweets = tweepy.Cursor(api.search,q=text_query, since=today).items(count)
 
 # Pulling information from tweets iterable object
 tweets_list = [[tweet.created_at, tweet.id, tweet.text] for tweet in tweets]
 
 # Creation of dataframe from tweets list
 # Add or remove columns as you remove tweet information
 tweets_df = pd.DataFrame(tweets_list, columns = ['time_created', 'id', 'text'])
 
except BaseException as e:
    print('failed on_status,',str(e))
    time.sleep(3)

tweets_df.to_csv('twitter.csv', index=False) 
print(timestamp)
print(tweets_df['time_created'].iloc[99].timestamp())
print(tweets_df['time_created'].iloc[99].timestamp() > (timestamp))
print(tweets_df['time_created'].iloc[0].timestamp() > (timestamp))
