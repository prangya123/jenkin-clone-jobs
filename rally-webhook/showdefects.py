#!/usr/bin/env python

#################################################################################################
# required python3 , pyral
#  showdefects -- show defects in a workspace/project conforming to some common criterion
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#   Dec-25-2017    Prangya P Kar      Intial Version
#
# python3 showdefects.py -c rallyuser.cfg -e QA01
# python3 showdefects.py --config_file devops-rallyuser.cfg --environment QA01
#
#criterion:
#   PromotedImpactedEnvironment = QA01 and State = Closed and VerifiedEnvironment = QA01 and Resolution = Code Change
#   Exclude Projects =  'The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor','Green Beret'

#################################################################################################

import sys, os, csv
import getopt
import og_utils
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
  usage_message_main1 = ("Usage: " + __file__ + "[--help] --config_file <config_file> --environment <environment>")
  usage_message_main2 = ("Usage: " + __file__ + " [-h] -c <config_file> -e <environment>")
  usage_message_add = ("[Environment Promotion list of Defect(s)] This script lists all  Defect(s) which are ready for promotion for a specified environment")
  print (usage_message_main1)
  print("OR")
  print(usage_message_main2)
  print(usage_message_add)
  print("\n")

#################################################################################################
QUERY_FILE = 'rally_defect_config.json'

def main(args):
    environment = None
    config_file = None
    try:
        opts, args = getopt.getopt(args, "h:c:e:", ["config_file=", "environment=", "help="])
    except getopt.GetoptError as exc:
        print(exc.msg)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(0)

        elif opt in ("-c", "--config_file"):
            config_file = arg
        elif opt in ("-e", "--environment"):
            environment = arg

    rally_input = []
    input = "--config=" + config_file
    rally_input.append(input)
    server, username, password, apikey, workspace, project = rallyWorkset(rally_input)

    if apikey:
        rally = Rally(server, apikey=apikey, workspace=workspace, project=project)
    else:
        rally = Rally(server, user=username, password=password, workspace=workspace, project=project)

    projects = rally.getProjects(workspace)

    entity_name = 'Defect'

    stageFile = 'outputResultD.csv'
    #finalFile = 'finalResultsD.csv'
    finalFile = 'splitResultsD.csv'
    finalSortedFile = 'sortedResultD.csv'
    header = 'FormattedID | VerifiedinBuildTOBEUSED | Name | State | FixedInBuild | PromotedImpactedEnvironment'
    finalHeader = 'FormattedID|VerifiedinBuildTOBEUSED|Name'
    temp = sys.stdout
    stdoutFile = open(stageFile, 'w')
    sys.stdout = stdoutFile


    if os.path.isfile(QUERY_FILE) is False:
        err_msg = "File ["+QUERY_FILE+"] is not present."
        raise AttributeError(err_msg)

    query_file_map = og_utils.load_json(QUERY_FILE)
    if environment in query_file_map:
        rally_query = query_file_map[environment]
    else:
        error_message = "There is no entry for "+environment+ " in the file "+QUERY_FILE
        raise AttributeError(error_message)

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
        print(header)
        for proj in projects:
            # print("    %12.12s  %s" % (proj.oid, proj.Name))
            response = rally.get(entity_name, fetch=True, query=rally_query, order='VerifiedinBuildTOBEUSED',
                                 workspace=workspace, project=proj.Name)
            response.encoding = "utf-8"
            if response.resultCount > 0 and proj.Name not in [ 'The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor','Green Beret']:
                #print("Workspace Name: %s , Project Name: %s , Entity Name: %s " % (
                #workspace, proj.Name, entity_name))
                for defect in response:
                    #print("%12.12s|%-52.52s|%-6.6s|%-30.30s|%-55.55s|%-8.8s" % (
                    # print("%s|%s|%s|%s|%s|%s" % (
                    # defect.FormattedID, defect.Name, defect.State, defect.VerifiedInBuild, defect.FixedInBuild,
                    # defect.PromotedImpactedEnvironment))
                    #print("%s|%s" % ( defect.FormattedID,defect.FixedInBuild))
                    # if ',' in defect.VerifiedInBuild:
                    #     verifiedInBuildSplit = defect.VerifiedInBuild.split(',')
                    #     for i in verifiedInBuildSplit:
                    #         print("%s|%s|%s|%s|%s|%s" % (defect.FormattedID, defect.Name, i, defect.State, defect.FixedInBuild, defect.PromotedImpactedEnvironment))
                    # else:
                    #    print("%s|%s|%s|%s|%s|%s" % (defect.FormattedID, defect.Name, defect.VerifiedInBuild, defect.State, defect.FixedInBuild, defect.PromotedImpactedEnvironment))
                    FixedInBuild = defect.FixedInBuild
                    if FixedInBuild != None:
                        FixedInBuild = FixedInBuild.encode("utf-8")

                    VerifiedinBuildTOBEUSED = defect.VerifiedinBuildTOBEUSED
                    if VerifiedinBuildTOBEUSED != None:
                        VerifiedinBuildTOBEUSED = VerifiedinBuildTOBEUSED.encode("utf-8")

                    print("%s|%s|%s|%s|%s|%s" % (
                    defect.FormattedID, VerifiedinBuildTOBEUSED, defect.Name, defect.State, FixedInBuild,
                    defect.PromotedImpactedEnvironment))
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
                            f2.write("%-8.8s|%s|%s\n" % (
                                line.split('|')[0], i.strip() ,line.split('|')[2]))
                    else:
                        f2.write("%-8.8s|%s|%s\n" % (
                            line.split('|')[0], line.split('|')[1], line.split('|')[2]))

        # Now sort the finalFile and write into finalSortedFile
        with open(finalFile, mode='rt') as f, open(finalSortedFile, 'w') as final:
            writer = csv.writer(final, delimiter='|')
            reader = csv.reader(f, delimiter='|')
            _ = next(reader)
            result = sorted(reader, key=lambda row: row[1])
            final.write(finalHeader + '\n')
            for row in result:
                writer.writerow(row)

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
