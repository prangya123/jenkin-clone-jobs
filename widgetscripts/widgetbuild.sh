#!/bin/bash

##### ADDED BELOW FOR ENV SPECIFIC WIDGETS

targetpath="bin"

for env in `cat $envnames`
do
	echo
	echo "Starting for $env......."
	echo "--------------------------------------------------------------------------------------------"
           
    
    file_name=metadata-$env.json
    
	cd $WORKSPACE
    
    for each_widget in `cat $envspecificfolders`
    do
         
                  if [ -d "$targetpath/$each_widget" ]
                  then
                      if [ -f "$targetpath/$each_widget/$file_name" ]
                          then
                              echo "COPYING: $targetpath/$each_widget/$file_name TO $targetpath/$each_widget/metadata.json"
                              cp $targetpath/$each_widget/$file_name $targetpath/$each_widget/metadata.json
                          else
                              echo "ERROR: $targetpath/$each_widget/$file_name expected, but does not exist!"
                              exit 1
                      fi
                  else
                          echo "ERROR: $each_widget is expected, but does not exist!"
                          exit 1
                  fi
    done

   

	mkdir -p $WORKSPACE/Artifacts

    
    cd $WORKSPACE/Artifacts
    echo
    echo "Creating an artifact for $env.."
	tar cfz Dashboard_Widgets_${env}.tar.gz -X $WORKSPACE/genericwidgets.txt ../bin
	echo "Dashboard_Widgets_${env}.tar.gz is now created for $env "
   
done



tar cfz Dashboard_Widgets_Generic.tar.gz -X $WORKSPACE/envspecificwidgets.txt ../bin

cd $WORKSPACE
tar cfz Dashboard_Widgets_${BUILD_NUMBER}.tar.gz Artifacts/*.tar.gz
