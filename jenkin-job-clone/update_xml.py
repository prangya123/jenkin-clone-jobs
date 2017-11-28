#!/usr/bin/env python

################################################################################################################################
#  required python3
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Nov 21, 2017    Prangya P Kar      Intial Version
#
# This is to replace the string inside the config.xml like followings:-
# if found string "OGD_Development_USWest_01" to "Oil&amp;Gas_Product_Demo"
# if found string "dev01" to "demodev02"
#
# arguments[0] : is the folder where to find all the config.xml files
# args : <path to config files> sourceOrg destinOrg sourceSpace destinSpace
# sourceOrg destinOrg sourceSpace destinSpace = OGD_Development_USWest_01 "'Oil&amp;Gas_Product_Demo'" dev01 demodev02
#
# e.g:
# python3 update_xml.py /Users/prangyakar/PycharmProjects/create_ci_job OGD_Development_USWest_01 "'Oil&amp;Gas_Product_Demo'" dev01 demodev02
#
# ################################################################################################################################

import os
import sys

arguments = []
indx = 0

def read_configfile(arguments, fileName):
    with open(fileName) as f:
        entireFile = f.read()
        #if "--suite" in entireFile:
        if arguments[1] or arguments[3] in entireFile :
           # newText = entireFile.replace("--AAAA2222", "--suite")
            newText = entireFile.replace(arguments[1], arguments[2]).replace(arguments[3],arguments[4])
            return {fileName: newText}
    f.close()
    return {}

def write_file(fileName, textToWrite):
    with open(fileName, "w") as f:
        f.write(textToWrite)
    f.close()

def find_config(args):
    cnt = len(args)
    print(cnt)
    for i in args:
        arguments.append(i)
        #indx=indx+1

    for root, dirs, files in os.walk(arguments[0], topdown=False):
        for name in files:
            if name.lower().endswith('.xml'):
                f = os.path.join(root,name)
                print(f)
                gitFile = read_configfile(arguments, f)
                if gitFile != {}:
                    for k, v in gitFile.items():
                        write_file(k, v)
                        print(k)

if __name__ == "__main__":
    ''' replacing a string '''
    find_config(sys.argv[1:])
    sys.exit(0)
