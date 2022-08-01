#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 18 10:41:51 2022

@author: akmami
"""
import urllib.request, json
from  pymongo import MongoClient

api_key = '62270ed9289769.07716311'

def get_exchange_codes(event, context):
    eod_url = "https://eodhistoricaldata.com/api/exchanges-list/?api_token="+api_key+"&fmt=json"
    with urllib.request.urlopen(eod_url) as url:
        data = json.loads(url.read())
        us_exchanges = ['NYSE', 'NASDAQ', 'BATS', 'OTCQB', 'PINK', 'OTCQX', 'OTCMKTS', 'NMFQS', 'NYSE MKT','OTCBB', 'OTCGREY', 'BATS', 'OTC']
        for item in us_exchanges:
            us = {}
            us['Name'] = item
            us['Code'] = 'US'
            us['OperatingMIC'] = None
            us['Country'] = 'USA'
            us['Currency'] = 'USD'
            data.append(us)
        data.pop(0)
        return {
            'statusCode': 200,
            'data': data
        }
    return {
        'statusCode': 400,
        'data': 125
    }

def get_tickers(event, context):
    
    if 'exchange_code' not in event:
        return {
            'statusCode': 400,
            'errorType': 100
        }
    exchange_code = event['exchange_code']
    
    eod_url = "https://eodhistoricaldata.com/api/exchange-symbol-list/"+exchange_code+"?api_token="+api_key+"&fmt=json"
    with urllib.request.urlopen(eod_url) as url:
        data = json.loads(url.read())
        return {
            'statusCode': 200,
            'data': data
        }
    
    return {
        'statusCode': 400,
        'data': 125
    }


exchange_codes = get_exchange_codes(None, None)

myclient = MongoClient("mongodb+srv://pport:pport123@pport.anzux.mongodb.net/pport?retryWrites=true&w=majority")
mydb = myclient["pport"]
mycol = mydb["exchanges"]

for exchange in exchange_codes['data']:
    code = exchange['Code']
    country = exchange['Country']
    currency = exchange['Currency']
    name = exchange['Name']
    operating_mic = exchange['OperatingMIC']
    mydict = { "code": code, "country": country, "currency": currency, "name": name, "operating_mic": operating_mic}
    mycol.insert_one(mydict)
    print(code)
