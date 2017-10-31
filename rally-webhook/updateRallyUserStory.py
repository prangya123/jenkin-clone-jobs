#!/usr/bin/env python

#################################################################################################
#  required python3 , pyral
#  updatedefects -- update defects in a workspace/project
#  to run: python3 updateRallyUserStory.py <FormattedID> <FoundInBuild> <FixedInBuild> <VerifiedInBuild> <ScheduleState> <c_PromotedtoEnvironment> --config=rallyuser.cfg
#
#  e.g.: python3 updateRallyUserStory.py DE47147 build303 build909 DEV01 Accepted Dev01  --config=rallyuser.cfg
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

    if len(args) < 2:
        errout(USAGE)
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

    proj = rally.getProject()

    userStoryID, fixedBuild, verifiedinBuild, scheduleState = args[:4]

    userStory_data = {"FormattedID": userStoryID,
                   "FixedInBuild": fixedBuild,
                   "VerifiedInBuild": verifiedinBuild,
                   "ScheduleState": scheduleState
                   }

    # "KanbanState": kanbanState,
    # "KanbanStateDefofReady": kanbanStateDef
    try:
        userStory = rally.update('UserStory', userStory_data)
    except Exception:
        sys.stderr.write('ERROR: %s \n')
        sys.exit(1)

    print("Defect %s updated" % userStory.FormattedID)


#################################################################################################
#################################################################################################

if __name__ == '__main__':
    main(sys.argv[1:])

    sys.exit(0)