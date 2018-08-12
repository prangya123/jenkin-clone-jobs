# This is to clone the jenkin jobs using RESTAPI

#required


#get list of jenkin jobs using RESTAPI
jenkinjobLIST.sh folderViewName --config jenkin_param.cfg


#get config.xml for each ci job using RESTAPI
jenkinjobGET.sh jenkinJobPath oldSpace --config jenkin_param.cfg


#update each xml to replace the new org and space value
python3 actual-update_xml.py arguments[0] sourceOrg destinOrg sourceSpace destinSpace
arguments[0]: is the folder where to find all the config.xml files, mostly it will be the jenkin workspace.


#create job using POST
jenkinjobPOST.sh folderViewName jenkinJobPath oldSpace newSpace --config jenkin_param.cfg



#disable jenkin jobs using RESTAPI
jenkinjobDISABLE.sh folderViewName jenkinJobPath --config jenkin_param.cfg
