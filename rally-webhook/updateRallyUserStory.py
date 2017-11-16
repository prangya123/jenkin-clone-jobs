#!/usr/bin/env python

#################################################################################################
#  required python3 , pyral
#  updatedefects -- update defects in a workspace/project
#  to run: python3 updateRallyUserStory.py <FormattedID> <PromotedImpactedEnvironment> --config=rallyuser.cfg
#
#  e.g.: python3 updateRallyUserStory.py US47147 QA01  --config=rallyuser.cfg
#
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Oct,25.2017    Prangya P Kar      Intial Version
#
#
#
#################################################################################################

import sys
from pyral import Rally, rallyWorkset
import argparse

USAGE = """
Usage: updateRallyUserStory.py <FormattedID> <Attributes...>
"""
#################################################################################################

errout = sys.stderr.write


#################################################################################################

def main(args):
    options = [opt for opt in sys.argv[1:] if opt.startswith('--')]
    args    = [arg for arg in sys.argv[1:] if arg not in options]
    server, username, password, apikey, workspace, project = rallyWorkset(options)

    # if len(args) < 2:
    #     errout(USAGE)
    #     sys.exit(2)
    if "-h" in args or "--help" in args or len(args) < 1:
        parser = argparse.ArgumentParser()
        parser.add_argument("[Please input 2 Parameters]", help="This script is to Update a given Defect")
        parser.add_argument("userStoryID, PromotedImpactedEnvironment",
                            help="Please provide required Defect attributes to update")
        result = parser.parse_args()
        sys.exit(2)
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
    entity_name = 'UserStory'

    userStoryID, PromotedImpactedEnvironment = args[:2]

    userStory_data = {"FormattedID": userStoryID,
                      "PromotedImpactedEnvironment": PromotedImpactedEnvironment
                     }

    ident_query = 'FormattedID = "%s"' % userStoryID

    try:
        for proj in projects:
            # print("    %12.12s  %s" % (proj.oid, proj.Name))
            response = rally.get(entity_name, fetch=True, query=ident_query,
                                 workspace=workspace, project=proj.Name)
            if response.resultCount > 0:
                print("Workspace Name: %s , Project Name: %s , Entity Name: %s , User Story Id: %s" %(workspace, proj.Name, entity_name, userStoryID))
                userStory = rally.update(entity_name, userStory_data, project=proj.Name)
                break

    except Exception:
        sys.stderr.write('ERROR: %s \n'+errout)
        sys.exit(1)

    print("\nUser Story %s updated with following attributes:" % userStoryID)
    print("FormattedID: " + userStoryID)
    print("PromotedImpactedEnvironment: " + PromotedImpactedEnvironment+"\n")


#################################################################################################
#################################################################################################

if __name__ == '__main__':
    main(sys.argv[1:])

    sys.exit(0)