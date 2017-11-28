#!/bin/sh

###############################################################################################################################
# This script creates jenkin jobs RESTAPI:
# Create jenkin jobs using the new config.xml
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Nov 21, 2017    Prangya P Kar      Intial Version
#
#
# e.g:
# ./jenkinjobPOST.sh Oil_and_Gas_Digital/job/DevOps-Jobs/job/Job-Cloning-Automation dev01 demodev02 --config jenkin_param.cfg
# ./jenkinjobPOST.sh <folderViewName> <jenkinJobPath> <oldSpace> <newSpace> --config jenkin_param.cfg
###############################################################################################################################
args="$@"
argCount=$#
configFile="jenkin_param.cfg"
cnt=0
jenkinJobPath="$1"
oldSpace="$2"
newSpace="$3"

#set proxy for predix
export http_proxy=http://sjc1intproxy10.crd.ge.com:8080
export https_proxy=http://sjc1intproxy10.crd.ge.com:8080

usage()
{
echo
echo Please use the script as below:
echo "$0 <folderViewName> <jenkinJobPath> <oldSpace> <newSpace> -config $configFile"
}

checkArg()
{
if [ $argCount -eq 0 ]; then
    echo "***ERROR***"
    echo "No Input Parameter. Exiting..."
    usage
    exit 1
 else
    for var in args
    do
        i=$i+1
        if [ var == "-config" ]; then
            if [ "${i+1}" != "$configFile" ]; then
                echo "***ERROR***"
                usage
                exit 1
            fi
        else
            if [ $i -ne $argCount ]; then
                continue
            else
                echo "***ERROR***"
                usage
                exit 1
            fi
        fi
    done
fi
}

###Execution Starts here
checkArg

if ! [ -f $configFile ]; then
    echo "Config file does not exists"
    exit 1
fi

array=() # Create array
    while IFS= read -r line # Read a line
    do
     array+=("$line")
done < $configFile

for i in "${array[@]}"
do
echo $i
done

echo ${array[0]}

#post or create new jenkin jobs using the updated config.xml
while read line
do
    #echo "curl -s -X POST ''https://${array[1]}:${array[2]}@${array[0]}/job/${jenkinJobPath}/createItem?name=${line}-${newSpace}'' --data-binary @${line}-${oldSpace}.xml -H ''Content-Type:text/xml''"
    curl -s -X POST ''https://${array[1]}:${array[2]}@${array[0]}/job/${jenkinJobPath}/createItem?name=${line}-${newSpace}'' --data-binary @${line}-${oldSpace}.xml -H ''Content-Type:text/xml''
done < joblist.csv