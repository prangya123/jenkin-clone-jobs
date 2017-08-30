#!/bin/bash

echo
echo "Starting Widget Validation......."
echo "---------------------------------"

cd scripts

validationresults="./widgetvalidation_result.txt"
cat /dev/null > $validationresults

validation=$(node widgetsCheck.js)
echo "${validation}" >> $validationresults

if [[ ! -z $(grep "Widgets that need to be fixed" "$validationresults") ]]
then 
	echo "Widget Validation check failed"
	cat $validationresults
	exit 1
else
	cat $validationresults
fi

cd ..
echo "Widget validation is Complete!"
echo "---------------------------------"
