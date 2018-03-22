#!/usr/bin/env python

####################################################################################################################################################################
#  required python3
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Dec 01, 2017    Prangya P Kar      Intial Version
#
# This is to create new jenkin jobs
#
# python3 postResponse.py <user> <apiKey> <jobNameExt>
#
# e.g:
# python3 postResponse.py 212609073 14d41061aa074a986dd708daed1a5f30 Oil_and_Gas_Digital/view/jenkin-clone-automation-poc/ PERF_PAMM22
# curl -s -X POST https://212609073:14d41061aa074a986dd708daed1a5f30@predix1.jenkins.build.ge.com/job/Oil_and_Gas_Digital/job/DevOps-Jobs/job/Job-Cloning-Automation/createItem?name=DUMMY0000_Single_Well_Intellistream-LOWERPOC2 --data-binary @DUMMY02_Single_Well_Intellistream-LOWERPOC1.xml -H Content-Type:text/xml
#
# python3 postResponse.py 212609073 14d41061aa074a986dd708daed1a5f30 LOWERPOC2 LOWER LOWER
# python3 postResponse.py 212609073 14d41061aa074a986dd708daed1a5f30 LOWERPOC2 LOWER HIGHER
# First create a folder i.g BFX01, Also please make sure the folder is added into script as part of lower or higher env in writePostConfigXml (LINE 64-68)
# ###################################################################################################################################################################

import requests
import json
import sys
import re
import os

arguments = []
indx = 0
url = 'predix1.jenkins.build.ge.com'

os.environ["http_proxy"] = "http://sjc1intproxy10.crd.ge.com:8080"
os.environ["https_proxy"] = "http://sjc1intproxy10.crd.ge.com:8080"


print ("This is the name of the script: ", sys.argv[0])
print ("Number of arguments: ", len(sys.argv))
print ("The arguments are: " , str(sys.argv))

print(os.environ)

fileName = 'joblist.txt'
fileNameDerived = 'joblistDerived.txt'
fileNamePost = "joblistPost.txt"
entireLine=[]
newLine=''

# code starts below
def write_args(args):
    cnt = len(args)
    for i in args:
        arguments.append(i)

def writePostConfigXml(arguments, fileName, fileNamePost):
    with open(fileName) as f1:
        with open(fileNamePost, 'a') as f2:
            lines = f1.readlines()
            for line in lines:
                jobName = line.split('/')[-2]
                preJobName = jobName.split('-')[-1]
                postJobName = jobName.rsplit('-',1)[0]

                if arguments[-1].upper() == 'LOWER':
                #if arguments[2].upper() in ['PERF01', 'DEV01', 'DEV02', 'QA01', 'QA02', 'LOWERPOC1', 'LOWERPOC2']: #lower target env
                    if arguments[-2].upper() == 'LOWER':
                    #if preJobName.upper() in ['PERF01', 'DEV01', 'DEV02', 'QA01', 'QA02', 'LOWERPOC1', 'LOWERPOC2']: #lower source env
                        newLine=line.rsplit('/',3)[0]+'/createItem?name='+ postJobName + '-' + arguments[-3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml\n'
                        f2.write(newLine)

                elif arguments[-1].upper() == 'HIGHER':
                #elif arguments[2].upper() in ['UAT01', 'DEMODEV01', 'DEMODEV02','DEMOPROD02', 'BFX01', 'PAMMITEMP01','PAMMITEMP02']: #higher target env
                    if arguments[-2].upper() == 'HIGHER':
                    #if preJobName.upper() in ['UAT01', 'DEMODEV01', 'DEMODEV02','DEMOPROD02', 'BFX01', 'PAMMITEMP01','PAMMITEMP02']: #higher source env
                        #newLine=line.rsplit('/',3)[0]+'/createItem?name='+ postJobName + '-' + arguments[2] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml\n'
                        newLine = line.rsplit('/', 4)[0] +'/'+ arguments[-3] +'/createItem?name=' + postJobName + '-' + arguments[-3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml\n'
                        f2.write(newLine)
                    else:  #else lower souce to higher target
                        # url = 'curl -XGET https://212609073:14d41061aa074a986dd708daed1a5f30@predix1.jenkins.build.ge.com/job/Oil_and_Gas_Digital-HEnv/checkJobName?value=Job-Cloning-Automation'
                        # print(url)
                        # # Do the HTTP get request
                        # response = os.system(url)  # Verify is check SSL certificate
                        # print(response)
                        #
                        # newLine = line.rsplit('Oil_and_Gas_Digital')[0]+'Oil_and_Gas_Digital-HEnv/job/'+line.split('/')[-4]+ '/createItem?name=' + postJobName + '-' \
                        #           + arguments[3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml\n'
                        newLine = line.rsplit('Oil_and_Gas_Digital')[0] + 'Oil_and_Gas_Digital-HEnv/job/'+ arguments[-3] +'/createItem?name=' + \
                                postJobName + '-' \
                                + arguments[-3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml\n'
                        f2.write(newLine)

'''
def writePostConfigXml(arguments, fileName, fileNamePost):
    with open(fileName) as f:
        entireFile = f.read()
        if arguments[2].split('/')[0] in entireFile:
            if arguments[3].upper() in ['PERF01', 'DEV01', 'DEV02', 'QA01', 'QA02', 'PAMMIDEV01','PAMMIDEV02']: #only use PAMMIDEV01 paste in PAMMIDEV02
                #newText = entireFile.replace(arguments[2].split('/')[0], arguments[2]) #jobpath same if both lower
            with open(fileNamePost, "w") as ff:
                ff.write(newText)
'''
'''
#jobpath same if both upper then no change in jobpath
#jobpath diff if one is lower and post in upper or viceversa
#can do automation if we get response form lower and post response in higher viceversa is not possible.
#Oil_and_Gas_Digital/view/DEV01/job/OG-Mumbai_Team/job/APM-Onshore-AlertGeneration/job/APM-Onshore-AlertGeneration-DEV01/
#Oil_and_Gas_Digital-HEnv/view/DEMODEV01/job/APM-Onshore-AlertGeneration/job/APM-Onshore-AlertGeneration-DEMODEV01/
    with open(fileNamePost, 'w') as f:
        for line in entireLine:
            if arguments[2].split('/')[0] in line:
                if arguments[3].upper() in ['UAT01', 'DEMODEV01', 'DEMODEV02', 'QA01', 'QA02', 'PAMMIUAT01','PAMMIUAT02']: 
                    newLine = line.replace(arguments[2].split('/')[0], arguments[2])
                f.write(newLine)
'''

# read file joblistDerived.csv
def postConfigXml(arguments, fileNamePost):
    with open(fileNamePost) as f:
        for line in f:
            line=re.sub(r'^"|"$', '', line)
            line = re.sub(r'\n$', '', line)
            print("inside postConfigXml")
            print(line)
            jobName = line.split('/')[-2]
            print(jobName)
            print(arguments[0])
            postJobName = jobName.split('-')[-2]
            #urlPart1 = line[:line.index(arguments[0])+len(arguments[0])]
            #print(urlPart1)
          #  str = 'curl -s -X POST https://'+arguments[0]+':'+arguments[1]+'@'+url+'/job/'+arguments[2]+'createItem?name='+postJobName+'-'+arguments[3]+' --data-binary @'+jobName+'.xml -H Content-Type:text/xml'
          #  str = 'curl -s -X POST https://' + arguments[0] + ':' + arguments[1] + '@' + url + '/job/' + arguments[2] + 'createItem?name=' + postJobName + '-' + arguments[3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml'
          #  str = 'curl -s -X POST '+ line.rsplit('/',2)[0] + '/createItem?name=' + postJobName + '-' + arguments[3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml'
          #  str =  'curl -s -X POST '+ line + '/createItem?name=' + postJobName + '-' + arguments[3] + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml'
            str = 'curl -s -X POST ' + line
            print(str)
            os.system(str)



# code ends

#main start
if __name__ == "__main__":
    write_args(sys.argv[1:])
    open(fileNamePost, 'w').close()
    writePostConfigXml(arguments,fileNameDerived, fileNamePost)
    postConfigXml(arguments, fileNamePost)
    sys.exit(0)


