#!/usr/bin/env python3 -tt
#-*- coding: UTF-8 -*-

"""
v0.1: First stage of identifying in-scope sub-domains for Uber BB program (based on https://hackerone.com/uber)
"""

import requests
import re

browser = requests.session()
browser.headers['Accept']='application/json, text/javascript, */*; q=0.01'
browser.headers['Referer']='https://hackerone.com/uber'
browser.headers['User-Agent']='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:62.0) Gecko/20100101 Firefox/62.0'
browser.headers['X-Requested-With']='XMLHttpRequest'

hackuberresp = browser.get("https://hackerone.com/uber")
hackubertext = hackuberresp.content.decode('utf-8')

possdomains = re.findall(r'look\sat:(.*?[<\\])',hackubertext)

domainset = set()

for eachdom in possdomains:
    domainset.update(eachdom.split())

justdomains = set()

for eachdom in domainset:
    justdomains.update(re.findall(r'[\w\.]+',eachdom))

domainlist = list(justdomains)

with open("/tmp/uber_domains.txt","a") as outfile:
    outfile.write("\n".join(domainlist))