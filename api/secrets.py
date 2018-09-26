#!/usr/bin/env python

import json

def get(path):
	with open(path+'/api_secret.json') as f:
	    data = json.load(f)
	return (data['zone_name'], data['email'], data['token'], data['certtoken'])
