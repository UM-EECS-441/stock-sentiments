from utils import analyze_sentiment
import praw
from datetime import date, timedelta, timezone, datetime as dt
import pandas as pd


def reddit_func(LIMIT, text_query):
    # fetch posts
    reddit = praw.Reddit(client_id='GDOKPrBB4GK8CA', client_secret='h0duFt5U7GqKmjNXFe2CL45JJZ0', user_agent='StockSentiment')
    all_posts = reddit.subreddit('all')
    posts = []
    for post in all_posts.search(text_query, sort='top', time_filter = 'hour', limit=LIMIT):
        posts.append([post.title, post.created])

    # filter posts for the last 15 min
    posts = pd.DataFrame(posts, columns=['text', 'timestamp'])
    fifteen_min_ago = dt.now(tz=timezone.utc) - timedelta(minutes = 15)
    timestamp = dt.timestamp(fifteen_min_ago)
    past_fifteen_min = posts['timestamp'] >= timestamp
    posts = posts[past_fifteen_min]

    # calculate sentiment scores
    posts = analyze_sentiment(posts)
    return posts
