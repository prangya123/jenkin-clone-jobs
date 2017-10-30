#!/usr/bin/env python

#################################################################################################
#  required python3 , pyral
#  updatedefects -- update defects in a workspace/project
#  to run: python3 updateRallyDefect.py <FormattedID> <FoundInBuild> <FixedInBuild> <VerifiedInBuild> <ScheduleState> <c_PromotedtoEnvironment> --config=rallyuser.cfg
#
#  e.g.: python3 updateRallyDefect.py DE47147 build303 build909 DEV01 Accepted Dev01  --config=rallyuser.cfg
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
Usage: updateRallyDefect.py <FormattedID> <Attributes...>
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

    # python3 updateRallyDefect.py <Defect FormattedID> <foundBuild> <fixedBuild> <scheduleState> <promotedtoEnvironment>.....
    #defectID, foundBuild, fixedBuild, scheduleState = args[:4]
    # defectID, foundBuild, fixedBuild, verifiedinBuild, scheduleState, promotedtoEnvironment, kanbanState, kanbanStateDef = args[:8]

    defectID, foundBuild, fixedBuild, verifiedinBuild, scheduleState, promotedtoEnvironment = args[:6]

    defect_data = {"FormattedID": defectID,
                   "FoundInBuild": foundBuild,
                   "FixedInBuild": fixedBuild,
                   "VerifiedInBuild": verifiedinBuild,
                   "ScheduleState": scheduleState,
                   "c_PromotedtoEnvironment": promotedtoEnvironment
                   }

    # "KanbanState": kanbanState,
    # "KanbanStateDefofReady": kanbanStateDef
    try:
        defect = rally.update('Defect', defect_data)
    except Exception:
        sys.stderr.write('ERROR: %s \n')
        sys.exit(1)

    print("Defect %s updated" % defect.FormattedID)


#################################################################################################
#################################################################################################

if __name__ == '__main__':
    main(sys.argv[1:])

    sys.exit(0)
