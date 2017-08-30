#!/bin/bash


allwidgetfolders="./allwidgets.txt"
cat /dev/null > $allwidgetfolders

genericwidgetfolders="./genericwidgets.txt"
cat /dev/null > $genericwidgetfolders

envspecificfolders="./envspecificwidgets.txt"
cat /dev/null > $envspecificfolders

envnames="./environments.txt"
cat /dev/null > $envnames


folderpath="bin"
dirpath=$folderpath

if [ $directories = "ALL" ]; then
  #ls -p $folderpath | tr '/' ',' | tr -d '\n' | sed 's/.$//' > $allwidgetfolders
  ls -p $folderpath | tr '/' ' ' > $allwidgetfolders
  #arr=$(cat $allwidgetfolders | tr "," "\n)
  arr=$(cat $allwidgetfolders)
  echo $arr
else
  echo $directories;
  arr=$(echo $directories | tr "," "\n")
  echo $arr
fi
  

echo
echo $env_specific_widgets | tr " " "\n" >> $envspecificfolders


for directory in $arr
do
	tempdirectory=$(cat ${envspecificfolders} | grep -o "$directory")
    if [[ $directory != $tempdirectory ]]
    then
    	echo $directory >> $genericwidgetfolders
    fi
done


echo
echo $Environments | tr " " "\n" >> $envnames
