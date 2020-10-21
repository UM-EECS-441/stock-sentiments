from django.shortcuts import render
from django.http import JsonResponse, HttpResponse

# Create your views here.

def gettickers(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    response['tickers'] = ['eecs441', '101.99', '+1']
    return JsonResponse(response)
