#!/usr/bin/env python

import json
import os

def get():
	with open(os.getcwd()+'/api_secret.json') as f:
	    data = json.load(f)
	return (data['zone_name'], data['email'], data['token'], data['certtoken'])
