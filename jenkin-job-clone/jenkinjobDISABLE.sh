#!/bin/sh

###########################################################################################################
# This script disables jenkin jobs using RESTAPI:
# Disable jenkin jobs for specific folders or view.
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#  Nov 21, 2017    Prangya P Kar      Intial Version
#
#
# e.g:
#./jenkinjobDISABLE.sh Oil_and_Gas_Digital/DevOps-Jobs/Job-Cloning-Automation  Oil_and_Gas_Digital/job/DevOps-Jobs/job/Job-Cloning-Automation --config jenkin_param.cfg
#./jenkinjobDISABLE.sh <folderViewName> <jenkinJobPath> --config jenkin_param.cfg

#
############################################################################################################
args="$@"
argCount=$#
configFile="jenkin_param.cfg"
cnt=0
folderViewName="$1"
jenkinJobPath="$2"


#set proxy for predix
export http_proxy=http://sjc1intproxy10.crd.ge.com:8080
export https_proxy=http://sjc1intproxy10.crd.ge.com:8080

usage()
{
echo
echo Please use the script as below:
echo "$0 <folderViewName> <jenkinJobPath> -config $configFile"
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

##List jenkin jobs for specific folder or view name
#java -jar jenkins-cli.jar -s https://${array[0]} list-jobs $folderViewName > jobliststodisable.csv


#read file jobliststodisable.csv
while read -r line
do
    #echo "curl -X POST https://${array[1]}:${array[2]}@${array[0]}job/${jenkinJobPath}/job/${line}/disable"
    curl -X POST https://${array[1]}:${array[2]}@${array[0]}job/${jenkinJobPath}/job/${line}/disable
done < jobliststodisable.csv

