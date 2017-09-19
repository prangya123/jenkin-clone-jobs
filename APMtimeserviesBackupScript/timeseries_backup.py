import getpass
import requests
import json
import time
import base64
import sys
import os

'''
import logging

try:
    import http.client as http_client
except ImportError:
    # Python 2
    import httplib as http_client
http_client.HTTPConnection.debuglevel = 1

# You must initialize logging, otherwise you'll not see debug output.
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())
'''


def get_injestor_token(config):
	oauth_url = config["uaa_url"] + "/oauth/token"
	client_id = config["uaa_client_id"]
	client_secret = config["uaa_client_secret"]
	username = config["username"]
	pswd = config["password"]

	#print (json.dumps(config))
	if client_secret is None:
		client_secret = getpass.getpass('Enter UAA Secret:')
		
	if pswd is None:
		#pswd = getpass.getpass('Enter Password:')
		pswd = str(sys.argv[2])

	payload = "grant_type=password&client_id=" + client_id + "&username=" + username + "&password=" + pswd
	basic_auth = base64.b64encode(client_id + ":" + client_secret)

	headers = {
		'content-type': "application/x-www-form-urlencoded",
		'authorization': "Basic " + basic_auth,
		'cache-control': "no-cache"
		}
		
	#print (json.dumps(headers))
	#print(payload)
	
	response = requests.request("POST", oauth_url, data=payload, headers=headers)
	#print response.text
	json_obj = json.loads(response.text)
	access_token =json_obj["access_token"]
	return access_token

def get_json(url,tenant,querystring,access_token):
	headers = {
		'tenant': tenant,
		'content-type': "application/json",
		'authorization': "Bearer " + access_token,
		'accept': "application/json",
		'cache-control': "no-cache"
		}
	#print (json.dumps(headers)) 
	response = requests.get(url, headers=headers, params=querystring)
	json_obj = json.loads(response.text)
	return json_obj


def download_data(config,access_token):
	url = config["asset_url"] + "/v1/tags/query"
	querystring = {"q":"name=*"}
	
	print("Writing file : " + "./" + config["tenant_name"] + "/tags.json")
	tags = get_json(url,config["tenant"],querystring,access_token)
	
	try:
		os.stat("./" + config["tenant_name"])
	except:
		os.mkdir("./" + config["tenant_name"]) 
    
	with open("./" + config["tenant_name"] + "/tags.json", 'w') as outfile:
		json.dump(tags, outfile, indent=4)
	
	for tag in tags:
		tagName = tag['sourceKey']
		timeseriesLink = tag['reservedAttributes']['timeseriesLink']
		url = config["timeseries_url"] + "/v2/time_series"
		if config["export_end_time"] is None:
			querystring = {"operation":"raw","tagList":timeseriesLink,"startTime":config["export_start_time"],"endTime":config["export_end_time"]}
		else:
			querystring = {"operation":"raw","tagList":timeseriesLink,"startTime":config["export_start_time"]}

		print("Writing file : " + "./" + config["tenant_name"] + "/" + timeseriesLink + ".json")
		timeseries_data = get_json(url,config["tenant"],querystring,access_token)
		with open("./" + config["tenant_name"] + "/" + timeseriesLink + ".json", 'w') as outfile:
			json.dump(timeseries_data, outfile, indent=4)
			
def main(argv):
	if(len(sys.argv)<2):
		print("Usage :" + "python timeseries_backup.py <configfile>")
		exit()
	

	with open(sys.argv[1]) as data_file:    
		config = json.load(data_file)	
		access_token = get_injestor_token(config)

	download_data(config,access_token)
    	

if __name__ == "__main__":
    main(sys.argv[1:])
