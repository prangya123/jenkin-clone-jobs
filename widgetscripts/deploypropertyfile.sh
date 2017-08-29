#!/bin/bash

echo
echo "Generating a property file for Dev01 widgetpush"
echo "*****************************************"
touch deploy.properties
echo "Environment=dev01" >> deploy.properties
echo "Artifact_Number=$BUILD_NUMBER" >> deploy.properties
echo "Done with deploy.properties file creation"
echo "*****************************************"
