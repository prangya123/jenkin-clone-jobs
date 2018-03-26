#!/usr/bin/env python

#################################################################################################
# required python3 , pyral
#  showdefects -- show defects in a workspace/project conforming to some common criterion
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Dec,25.2017    Prangya P Kar      Intial Version
#
# python3 showdefects.py --config=rallyuser.cfg
#
#criterion:
#   PromotedImpactedEnvironment = QA01 and State = Closed and VerifiedEnvironment = QA01 and Resolution = Code Change
#   Exclude Projects =  'The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor','Green Beret'
#
#################################################################################################

import sys, os
from pyral import Rally, rallyWorkset, RallyRESTAPIError
import argparse


# USAGE = """
# Usage: showuserstories.py
# """
#################################################################################################

errout = sys.stderr.write


#################################################################################################
def usage():
  print ("\n")
  usage_message_main = ("Usage: " + __file__ + " [-h] [--help] --config=<configFile>")
  usage_message_add = ("[UAT Promotion lists of Defect(s)] This script is to lists all  Defect(s) which are ready for UAT promotions")
  print (usage_message_main)
  print(usage_message_add)
  print("\n")

#################################################################################################

def main(args):
    if "-h" in args or "--help" in args or len(args) < 1:
        usage()
        sys.exit(1)

    options = [opt for opt in sys.argv[1:] if opt.startswith('--')]
    args = [arg for arg in sys.argv[1:] if arg not in options]
    if len(options) < 1:
        usage()
        sys.exit(1)

    server, username, password, apikey, workspace, project = rallyWorkset(options)

    if apikey:
        rally = Rally(server, apikey=apikey, workspace=workspace, project=project)
    else:
        rally = Rally(server, user=username, password=password, workspace=workspace, project=project)

    projects = rally.getProjects(workspace)

    entity_name = 'Defect'

    stageFile = 'outputResultD.txt'
    finalFile = 'finalResultsD.txt'
    temp = sys.stdout
    stdoutFile = open(stageFile, 'w')
    sys.stdout = stdoutFile

    #ident_query = 'PromotedImpactedEnvironment = QA01 and State = Closed and VerifiedEnvironment = QA01 and Resolution = Code Change'
    ident_query = 'PromotedImpactedEnvironment = QA01 and State = Closed and VerifiedEnvironment = QA01 and Resolution = Code Change or Resolution = Configuration Change or Resolution = Database Change'
    # and Project = The Fellowship and Project != Hulk and Project != Hydra and Project != Shield and Project != Thor and Resolution = Code Change'
    try:
        # for proj in projects:
        #     # print("    %12.12s  %s" % (proj.oid, proj.Name))
        #     response = rally.get(entity_name, fetch=True, query=ident_query, order='VerifiedInBuild',
        #                          workspace=workspace, project=proj.Name)
        #     if response.resultCount > 0 and proj.Name not in [ 'The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor']:
        #         print("Workspace Name: %s , Project Name: %s , Entity Name: %s " % (
        #         workspace, proj.Name, entity_name))
        #         for defect in response:
        #             print("     %-8.8s  %-52.52s  %-12.12s %-8.8s %s %-20.20s " % (
        #             defect.FormattedID, defect.Name, defect.State, defect.VerifiedInBuild, defect.FixedInBuild,
        #             defect.PromotedImpactedEnvironment))
        #             #print("-----------------------------------------------------------------")
        #         print(response.resultCount, "qualifying defects")
        print(
            'FormattedID | VerifiedInBuild | NAME | State | FixedInBuild | PromotedImpactedEnvironment')
        for proj in projects:
            # print("    %12.12s  %s" % (proj.oid, proj.Name))
            response = rally.get(entity_name, fetch=True, query=ident_query, order='VerifiedInBuild',
                                 workspace=workspace, project=proj.Name)
            if response.resultCount > 0 and proj.Name not in [ 'The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor','Green Beret']:
                #print("Workspace Name: %s , Project Name: %s , Entity Name: %s " % (
                #workspace, proj.Name, entity_name))
                for defect in response:
                    #print("%12.12s|%-52.52s|%-6.6s|%-30.30s|%-55.55s|%-8.8s" % (
                    # print("%s|%s|%s|%s|%s|%s" % (
                    # defect.FormattedID, defect.Name, defect.State, defect.VerifiedInBuild, defect.FixedInBuild,
                    # defect.PromotedImpactedEnvironment))
                    #print("%s|%s" % ( defect.FormattedID,defect.FixedInBuild))
                    if ',' in defect.VerifiedInBuild:
                        verifiedInBuildSplit = defect.VerifiedInBuild.split(',')
                        for i in verifiedInBuildSplit:
                            print("%s|%s|%s|%s|%s|%s" % (defect.FormattedID, i, defect.Name, defect.State, defect.FixedInBuild, defect.PromotedImpactedEnvironment))
                    else:
                        print("%s|%s|%s|%s|%s|%s" % (defect.FormattedID, defect.VerifiedInBuild, defect.Name, defect.State, defect.FixedInBuild, defect.PromotedImpactedEnvironment))
                #print(response.resultCount, "qualifying defects")
        #print("===================================================================================================================================================================================================")
        stdoutFile.close()
        sys.stdout = temp

        # open(finalFile, 'w').close()
        with open(stageFile) as f1:
            with open(finalFile, 'w') as f2:
                lines = f1.readlines()
                for line in lines:
                    VerifiedinBuild = line.split('|')[1]
                    if ',' in VerifiedinBuild:
                        verifiedInBuildSplit = VerifiedinBuild.split(',')
                        for i in verifiedInBuildSplit:
                            f2.write("%s|%s\n" % (
                                line.split('|')[0], i))
                    else:
                        f2.write("%s|%s\n" % (
                            line.split('|')[0], line.split('|')[1]))
    except Exception:
        sys.stderr.write('ERROR:')
        usage()
        raise
        sys.exit(1)

    fields = "FormattedID,State,Name,Severity,Priority,FixedInBuild,VerifiedInBuild,PromotedImpactedEnvironment"





#################################################################################################
#################################################################################################

if __name__ == '__main__':
    main(sys.argv[1:])

    sys.exit(0)
