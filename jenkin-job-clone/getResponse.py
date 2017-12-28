#!/usr/bin/env python
################################################################################################################################
#  required python3
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Dec 01, 2017    Prangya P Kar      Intial Version
#
# This is to Download the config.xml files for each ci jobs under a specific jenkin view
#
#
# e.g:
# python3 getResponse.py 212609073 14d41061aa074a986dd708daed1a5f30 Oil_and_Gas_Digital/view/LOWERPOC1/
#
# ################################################################################################################################

import requests
import json
import sys
import re
import os

arguments = []
indx = 0
jenkinUrl = 'predix1.jenkins.build.ge.com'
url = ""

os.environ["http_proxy"] = "http://sjc1intproxy10.crd.ge.com:8080"
os.environ["https_proxy"] = "http://sjc1intproxy10.crd.ge.com:8080"


print ("This is the name of the script: ", sys.argv[0])
print ("Number of arguments: ", len(sys.argv))
print ("The arguments are: " , str(sys.argv))

print(os.environ)

fileName = 'joblist.txt'
fileNameDerived = 'joblistDerived.txt'

# code starts below


# code starts below
def write_args(args):
    cnt = len(args)
    for i in args:
        arguments.append(i)

#update the file with USER and APITOKEN
def write_joblist(arguments):
    with open(fileName) as f:
        entireFile = f.read()
        # if "--suite" in entireFile:
        if "https://" in entireFile:
            newText = entireFile.replace("https://", "https://" + arguments[0] + ":" + arguments[1] + "@")
            # return {fileName: newText}
            with open(fileNameDerived, "w") as ff:
                ff.write(newText)
            ff.close()

    f.close()

# read file joblistDerived.csv
def getConfigXml(fileNameDerived):
    with open(fileNameDerived) as f:
        for line in f:
            line=re.sub(r'^"|"$', '', line)
            line = re.sub(r'\n$', '', line)
            print("inside getConfigXml")
            print(line)
            jobName = line.split('/')[-2]
            print(jobName)
            str = 'curl -X GET '+line+'config.xml -o '+jobName+'.xml'
            print(str)
            os.system(str)

def getResponse(arguments):
    # Set the request parameters
    url = 'https://' + arguments[0] + ':' + arguments[1] + '@' + jenkinUrl + '/job/' + arguments[
        2] + 'api/json?pretty=true'
    print(url)
    # Do the HTTP get request
    response = requests.get(url, verify=True)  # Verify is check SSL certificate
    print(response.status_code)

    # Error handling
    # Check for HTTP codes other than 200
    if response.status_code != 200:
        print('Status:', response.status_code, 'Problem with the request. Exiting.')
        exit()
    json_data = requests.get(url).json()
    with open(fileName, 'w') as f:
        for i in json_data["jobs"]:
            print(i["url"])
            json.dump(i["url"], f)
            f.write('\n')
    f.close()



# Decode the JSON response into a dictionary and use the data

# code ends

#main start

if __name__ == "__main__":
    write_args(sys.argv[1:])
    getResponse(arguments)
    write_joblist(arguments)
    getConfigXml(fileNameDerived)
    sys.exit(0)


