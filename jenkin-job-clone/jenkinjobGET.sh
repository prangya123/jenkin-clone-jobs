#!/bin/sh

###########################################################################################################
# This script downloads the config.xml for each jenkin jobs using RESTAPI:
# Downlaod jenkin jobs config.xml files for specific folder or view.
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Nov 21, 2017    Prangya P Kar      Intial Version
#
#
# e.g:
#./jenkinjobGET.sh Oil_and_Gas_Digital/job/DevOps-Jobs/job/Job-Cloning-Automation dev01 --config jenkin_param.cfg
#./jenkinjobGET.sh <jenkinJobPath> <oldSpace> --config jenkin_param.cfg
############################################################################################################
args="$@"
argCount=$#
configFile="jenkin_param.cfg"
cnt=0
jenkinJobPath="$1"
oldSpace="$2"


#set proxy for predix
export http_proxy=http://sjc1intproxy10.crd.ge.com:8080
export https_proxy=http://sjc1intproxy10.crd.ge.com:8080

usage()
{
echo
echo Please use the script as below:
echo "$0 <jenkinJobPath> <oldSpace> -config $configFile"
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


#read file joblist.csv
while read -r line
do
    curl -X GET https://${array[1]}:${array[2]}@${array[0]}job/${jenkinJobPath}/job/${line}/config.xml -o ${line}-${oldSpace}.xml
    #echo "curl -X GET https://${array[1]}:${array[2]}@${array[0]}job/${jenkinJobPath}/job/${line}/config.xml -o ${line}-${oldSpace}.xml"
    #echo $line
done < joblist.csv

