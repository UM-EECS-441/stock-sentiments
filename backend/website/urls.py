"""website URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from app import views


urlpatterns = [
    path('admin/', admin.site.urls),
    path('get_tickers/', views.get_tickers, name='get_tickers'),
    path('get_watchlist_scores/', views.get_watchlist_score, name='get_watchlist_score'),
    path('user/subscribe/', views.subscribe, name='subscribe'),
    path('user/unsubscribe/', views.unsubscribe, name='unsubscribe'),
    path('update_sentiment/', views.update_sentiment, name='update_sentiment'),
    path('delete_old_sentiment/', views.delete_old_sentiment, name='delete_old_sentiment'),
    path('get_sentiment_score/', views.get_sentiment_score, name='get_sentiment_score'),
    path('sign_in/', views.sign_in, name='sign_in'),
    path('no_sign_in/', views.no_sign_in, name='no_sign_in'),
    path('toggle_notifications/', views.toggle_notifications, name='toggle_notifications'),
]
