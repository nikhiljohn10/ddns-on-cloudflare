#!/usr/bin/env python

import sys
import time
import requests

import CloudFlare
import secrets

class DDNS(object):
	def __init__(self,secret_path):
		super(DDNS, self).__init__()
		zone_name, email, token, certtoken = secrets.get(secret_path)
		self.zone_name = zone_name
		self.ip='0.0.0.0'
		self.dns = CloudFlare.CloudFlare(email = email, token = token, certtoken = certtoken)
		self.get_ip()
		self.get_zone_id()
		self.get_record_id()
		self.update_dns()
		self.worker()

	def worker(self):
		try:
			while True:
				self.get_ip()
				if self.check_ip():
					print("IP: %s" % (self.ip))
					time.sleep(60)
				else:
					print("New IP found. Updating Public IP...")
					self.get_zone_id()
					self.get_record_id()
					self.update_dns()
		except KeyboardInterrupt:
			raise
		finally:
			sys.exit(0)

	def check_ip(self):
		if self.ip == self.old_ip:
			return True
		return False

	def get_ip(self):
		url = 'https://api.ipify.org'
		try:
			ip_address = requests.get(url).text
			self.old_ip = self.ip
			self.ip = ip_address
		except:
			sys.exit('%s: failed' % (url))
		if ip_address == '':
			sys.exit('%s: failed' % (url))


	def get_zone_id(self):
		try:
			zones = self.dns.zones.get(params = {'name': self.zone_name})
			self.zone_id = zones[0]['id']
		except CloudFlare.exceptions.CloudFlareAPIError as err:
			sys.exit('/zones %d %s - api call failed' % (err, err))
		except Exception as e:
			sys.exit('/zones.get - %s - api call failed' % (err))

		if len(zones) == 0:
			sys.exit('/zones.get - %s - zone not found' % (self.zone_name))

		if len(zones) != 1:
			sys.exit('/zones.get - %s - api call returned %d items' % (self.zone_name, len(zones)))
		

	def get_record_id(self):
		dns_name = "ddns."+self.zone_name
		try:
			params = {'name':dns_name, 'match':'all', 'type':'A'}
			dns_records = self.dns.zones.dns_records.get(self.zone_id, params=params)
			if not dns_records:
				self.create_record()
			else:
				self.record_id = dns_records[0]['id']
		except CloudFlare.exceptions.CloudFlareAPIError as err:
			sys.exit('/zones/dns_records %s - %d %s - api call failed' % (dns_name, err, err))


	def create_record(self):
		try:
			record = {
				'name': "ddns."+self.zone_name,
				'type': 'A',
				'content': self.ip
			}
			dns_records = self.dns.zones.dns_records.post(self.zone_id, data=record)
			self.record_id = dns_records['id']
		except CloudFlare.exceptions.CloudFlareAPIError as err:
			sys.exit('/zones/dns_records %s - %d %s - api call failed' % (dns_name, err, err))

	def update_dns(self):
		record = {
			'name': "ddns."+self.zone_name,
			'type': 'A',
			'content': self.ip
		}
		try:
			self.record = self.dns.zones.dns_records.put(self.zone_id, self.record_id, data=record)
		except CloudFlare.exceptions.CloudFlareAPIError as err:
			sys.exit('/zones.dns_records.put %s - %d %s - api call failed' % (self.zone_name, err, err))
