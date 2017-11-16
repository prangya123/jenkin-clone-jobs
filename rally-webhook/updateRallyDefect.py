#!/usr/bin/env python

#################################################################################################
#  required python3 , pyral
#  updatedefects -- update defects in a workspace/project
#  to run: python3 updateRallyDefect.py <FormattedID> <PromotedImpactedEnvironment> --config=rallyuser.cfg
#
#  e.g.: python3 updateRallyDefect.py DE47147 QA01  --config=rallyuser.cfg
#
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Oct 25, 2017    Prangya P Kar      Intial Version
#  Nov 09, 2017    Prangya P Kar      Modified script to update PromotedImpactedEnvironment value for a given defect
#
#
#
#################################################################################################

import sys
from pyral import Rally, rallyWorkset
import argparse

#################################################################################################

errout = sys.stderr.write


#################################################################################################
def usage():
  print ("\n")
  usage_message_main = ("Usage: " + __file__ + " [-h] [--help] <defectID> <PromotedImpactedEnvironment> --config=<configFile>")
  usage_message_add = ("[Please input 2 Parameters] This script is to Update a given Defect")
  print (usage_message_main)
  print(usage_message_add)
  print("\n")


def main(args):
    if "-h" in args or "--help" in args or len(args) < 1:
        usage()
        sys.exit(1)

    options = [opt for opt in sys.argv[1:] if opt.startswith('--')]
    args    = [arg for arg in sys.argv[1:] if arg not in options]
    if len(args) < 2:
        usage()
        sys.exit(1)

    server, username, password, apikey, workspace, project = rallyWorkset(options)


    # if len(args) < 2:
    #     errout(USAGE)
    #     sys.exit(2)
    # if "-h" in args or "--help" in args or len(args) < 1:
    #     parser = argparse.ArgumentParser()
    #     parser.add_argument("[Please input 5 Parameters]", help="This script is to Update a given Defect")
    #     parser.add_argument("<defectID> <foundBuild> <fixedBuild> <scheduleState> <verifiedinBuild>",
    #                         help="Please provide required Defect attributes to update")
    #     result = parser.parse_args()
    #     sys.exit(2)
    # parser = argparse.ArgumentParser()
    # parser.add_argument("Description", help="This script is to Update a given Defect")
    # parser.add_argument("Update Defect",
    #                     help="Please provide required Defect attributes to update")
    # args = parser.parse_args()

    if apikey:
            rally = Rally(server, apikey=apikey, workspace=workspace, project=project)
    else:
            rally = Rally(server, user=username, password=password, workspace=workspace, project=project)

    projects = rally.getProjects(workspace)
    entity_name = 'Defect'

    # python3 updateRallyDefect.py <Defect FormattedID> <foundBuild> <fixedBuild> <scheduleState> <promotedtoEnvironment>.....
    #defectID, foundBuild, fixedBuild, scheduleState = args[:4]
    # defectID, foundBuild, fixedBuild, verifiedinBuild, scheduleState, promotedtoEnvironment, kanbanState, kanbanStateDef = args[:8]

    #defectID, foundBuild, fixedBuild, scheduleState, verifiedinBuild = args[:5]
    defectID, PromotedImpactedEnvironment = args[:2]

    defect_data = {"FormattedID": defectID,
                   "PromotedImpactedEnvironment": PromotedImpactedEnvironment
                   }

    ident_query = 'FormattedID = "%s"' % defectID
    try:
        for proj in projects:
            # print("    %12.12s  %s" % (proj.oid, proj.Name))
            response = rally.get(entity_name, fetch=True, query=ident_query,
                                 workspace=workspace, project=proj.Name)
            if response.resultCount > 0:
                print("Workspace Name: %s , Project Name: %s , Entity Name: %s , Defect Id: %s" %(workspace, proj.Name, entity_name, defectID))
                defect = rally.update(entity_name, defect_data, project=proj.Name)
                break

    except Exception:
        sys.stderr.write('ERROR:')
        usage()
        raise
        sys.exit(1)

    print("\nDefect %s updated with following attributes:" % defect.FormattedID)
    print("FormattedID: "+ defectID)
    print("PromotedImpactedEnvironment: "+ PromotedImpactedEnvironment+"\n")


#################################################################################################
#################################################################################################

if __name__ == '__main__':
    main(sys.argv[1:])

    sys.exit(0)
