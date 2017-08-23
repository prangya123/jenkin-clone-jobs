me="./sourcefile.txt"
cat /dev/null > $tempfilename

allwidgetdirfile="./alldirectories.txt"
cat /dev/null > $allwidgetdirfile

widgetfolders="./widgets.txt"
cat /dev/null > $widgetfolders

folderpath="bin"
dirpath=$folderpath

if [ "$directories" == "ALL" ]; then
  	ls -p $folderpath | tr '/' ',' | tr -d '\n' | sed 's/.$//' > $allwidgetdirfile
	arr=$(cat $allwidgetdirfile | tr "," "\n")
	echo $arr >> $widgetfolders
else
  	echo $directories;
  	arr=$(echo $directories | tr "," "\n")
  	echo $arr >> $widgetfolders
fi
 
echo "Listing WidgetFolders" 
cat $widgetfolders

for var in $arr;
do
   	echo "${dirpath}/${var}" >> $tempfilename
done


echo "Folder path in $tempfilename";
cat $tempfilename;

#cd $WORKSPACE
mkdir -p widgetsbin
#targetpath="$WORKSPACE/widgetsbin"
targetpath="widgetsbin"

for var1 in `cat $tempfilename`;
do
    echo "cp -r $var1 $targetpath";        
	cp -r $var1 $targetpath;
done

mv bin bintemp
mkdir bin
cp -a widgetsbin/. bin/


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


echo
echo "**************ENVIRONMENT SPECIFIC FILE CEHCK AND REPLACE METADATA.JSON FILE**************"


folderpath="$WORKSPACE/bin"

if [ "$whitelistedwidgets" == "enabled" ]
then
	echo "IMPORTANT- whilelist widget check is enabled here to skip environment specific file check for particular widget folders...." 
    declare -a whitelistedfolders
	whitelistedfolders=(ong-asset-overview ong-asset-summary ong-goals-kpi ong-non-kpi-count ong-watch-list)
    echo "Whitelisted widget folders - ${whitelistedfolders[@]}"
else
    echo "No Whitelisted widgets. Validation will continue for all widgets...."
fi


if [ "$Environments" == "ALL" ]
then
	declare -a Environments
	Environments=(dev01 qa01 perf01 uat01 demodev01 demoprod01)
fi
    

for env in "${Environments[@]}"
do
	echo
	echo "Starting for $env......."
	echo "--------------------------------------------------------------------------------------------"
	
    metadatafilename=metadata-${env}.json
    
  
    
    #for directory in "${directories[@]}"
    for directory in $arr
	do
			
		temp=$(echo ${whitelistedfolders[@]} | grep -o "$directory")
        
		
        if [[ $directory != $temp ]]
    	then 
    		echo	
        	echo "Widget Name: "$directory""
        	cd $folderpath/$directory
       
			mfile=$(find . -name "$metadatafilename" 2>/dev/null)
            
        	if [ "$mfile" == "" ]
        	then
        		echo "Oops!, There is no $metadatafilename in $directory. So exiting from the script. Please check with developer"
				exit 1
			else
	
				echo "The file $mfile is exist in $directory.."
			
				FILE=$(basename $mfile);
				DIR=$(dirname $mfile);
            
    			echo "COPYING: cp $DIR/$FILE $DIR/metadata.json"
				cp $DIR/$FILE $DIR/metadata.json					 	
			fi
  		fi
    
    done
	
	cd $WORKSPACE
    echo
    echo "Creating an artifact for $env.."
	tar cfz Dashboard_Widgets_${env}_${BUILD_NUMBER}.tar.gz bin
	echo "Dashboard_Widgets_${env}.tar.gz is now created for $env "
    echo "Publishing this artifact to Artifactory"
    curl -X PUT -u 502712493:AP3QVE55ZDfXm8giwQn6JSFfem6 https://devcloud.swcoe.ge.com/artifactory/XPIQO-SNAPSHOT/Widgets/testwidgets/ --upload-file Dashboard_Widgets_${env}_${BUILD_NUMBER}.tar.gz
      
done


echo
echo "Generating a property file for Dev01 widgetpush"
echo "*****************************************"
touch deploy.properties

echo "Environment=dev01" >> deploy.properties
echo "Artifact_Number=$BUILD_NUMBER" >> deploy.properties
echo "FOLDERS=$(cat $widgetfolders)" >> deploy.properties
echo "Done with deploy.properties file creation"
