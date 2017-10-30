#!/usr/bin/env python

#################################################################################################
#  required python3 , pyral
#  pre-commit.py -- extract the artibutes specific to defect or userstory in a workspace/project
#  to run: python3 pre-commit.py --config=rallyuser.cfg
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Oct,25.2017    Prangya P Kar      Intial Version
#
#
#
#################################################################################################
USAGE = """
Usage: pre-commit.py 
"""
#################################################################################################
import sys
import re
from pyral import Rally, rallyWorkset
errout = sys.stderr.write

def main (args):
    options = [opt for opt in args if opt.startswith('--')]
    args = [arg for arg in args if arg not in options]
    server, username, password, apikey, workspace, project = rallyWorkset(options)

    if apikey:
        rally = Rally(server, apikey=apikey, workspace=workspace, project=project)
    else:
        rally = Rally(server, user=username, password=password, workspace=workspace, project=project)

    rally.enableLogging('rally.hist.item') # name of file you want logging to go to

    retdata = getPreCommit()
    if retdata != 0:
        print ("Return Value: "+retdata)

    #entity_name, ident = args
    entity_name = 'Defect'

    ident_query = 'FormattedID = "%s"' % retdata


    response = rally.get(entity_name, fetch=True, query=ident_query,
                         workspace=workspace, project=project)

    if response.errors:
        errout("Request could not be successfully serviced, error code: %d\n" % response.status_code)
        errout("\n".join(response.errors))
        retFlag = 0

    if response.resultCount == 0:
        errout('No item found for %s %s\n' % (entity_name, retdata))
        retFlag = 0
    elif response.resultCount > 1:
        errout('WARNING: more than 1 item returned matching your criteria\n')
        retFlag = 0
    else:
        print("Time to commit")
        retFlag = 1

    if retFlag == 1:
        print("Commit here")


def getPreCommit():
    #line = " USERSTORY01 first commit in USER STORY US01"
   # print ("Read Line:       %s" % line)
    print("enter commit message")
    line = sys.stdin.readline()
    print (line)
    match = re.search(r'US[0-9]{2,5}|USERSTORY[0-9]{2,5}|DEFECT[0-9]{2,5}|DE[0-9]{2,5}',line)
    if match is not None:
        print ("commit message contains : ", match.group(0))
        fmtid = match.group(0)
        #getAttributeDetails.g('Defect DE47147 --config=pammi_bhge.cfg')
        #os.system("python3 getAttributeDetails.py Defect "+fmtid+" --config=pammi_bhge.cfg")
        return fmtid
    else:
        print("commit message do not have DE or US added, please add proper commit message")
        return 0

if __name__ == '__main__':
    main(sys.argv[1:])
    sys.exit(0)


    # import argparse
    #
    # parser = argparse.ArgumentParser()
    # parser.add_argument("Description", help="This script is to verify the commit message")
    # parser.add_argument("commit_message", help="Please add a valid commit message, starting with valid USERSTORY or DEFECT")
    # args = parser.parse_args()
    # #print(args.echo)

    #sys.exit(0)