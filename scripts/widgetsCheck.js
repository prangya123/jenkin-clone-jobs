#!/usr/bin/env node
/*
	instructions to run script:
	-> Have nodejs installed 
	-> Execution command: "node widgetsCheck.js"
	The execute command will default to path in "currentPath" variable (look below aka ./../dashboard-widgets/bin)
	if you want to switch path use "dir=path" where path is the directory for the widget/widgets you want to check
	if you just want to run it in a specific file use "singleDir=on" and specificy path to specific folder
		params: 
		dir=./../dashboard-widgets/bin.     will go into specified dir
		singleDir=on   			will just go in specific dir and check metadata.json, image, and vulc file
 */
var currentPath= "./../dashboard-widgets/bin"; //DEFAULT PATH current dir, goes up one dir then into dashboard widgets/bin
var fs = require( 'fs' );
var path = require( 'path' );
var process = require( "process" );
//default path to run script to if you want to change pass directory 
/*
	params: 
		dir=./../dashboard-widgets/bin.     will go into specified dir
		singleDir=on   						will just go in specific dir and check metadata.json, image, and vulc file
 */
var checkFailed = false;
var ignoreList= ["ong-mum.spider","ged.dashboard-data-table", "ged.graph", "ged.graph-interactive", "ged.monitor-and-diag","ged.open-cases","ged.unclaimed-alerts-events","ong-small-list","ong-kpi", "ong-bar", "mo-maintenance-kpi","mo.asset-recommendations","mo.asset-open-work-orders","mo.asset-criticality","ged.ambient-conditions"];
//array will store summary of widgets that need to be fixed
var errorOutput=[];
/**
 * [validateJSON description]
 * @param  {String} fileContent text of metadata.json file
 * @return {Boolean}             returns false/true if not valid
 */
function validateJSON(fileContent) {
	// body...
	try
	{
		var a = JSON.parse(fileContent);
		return true;
	}
	catch(e)
	{
		//throw error
		return false;
	}
}
//check fields
/**
 * [checkRequiredFields make sure it has the fields the api says it must have]
 * @param  {object} metadata for widget
 * @return {Boolean}          saying true/false
 * throws Error if not valid
 */
function checkRequiredFields(metadata) {
	//all metadata.json fields needed for v1
	var fields = ["id", "title", "description", "tenants", "version", "slug", "category", "author", "authorEmail", "properties"];
	var widgetFields= Object.keys(metadata);
	var errors= false;
	fields.forEach(function(val) {
		if(!widgetFields.includes(val))
		{
			console.error(`Widget: ${metadata.id} is missing ${val}`);
			errors = true;
		}
	});
	if(errors)
	{
		throw Error("Required Fields for metadata.json are not all available");
	}
	return errors;
}
/**
 * [shouldOnlyContain description]
 * @param  {object} metadata for widget
 * @param  {array} fields   array of strings that contain the fields
 * @return {Boolean}          saying true/false
 * throws Error if not valid
 */
function shouldOnlyContain(metadata, fields){
	//for all metadata.json files after v1
	//should contain only
	
	var widgetFields= Object.keys(metadata);
	var errors= false;
	widgetFields.forEach(function(val) {
		if(!fields.includes(val))
		{
			console.error(`Widget: ${metadata.id} has extra value: ${val}`);
			errors = true;
		}
	})
	if(errors)
	{
		throw Error("Has more fields than it should be");
	}
	return errors;
}
/**
 * regexTester tests if string passes regex
 * @param  {String} str   string to test
 * @param  {String} regex regex 
 * @return {Boolean}       true or false if passed regex
 */	
function regexTester(str, regex) {
    var patt = new RegExp(regex);
    var res = patt.test(str);
    return res;
}
//check naming conventions
function namingConventionsCheck(metadata, folder) {
	var success = true;
	if(folder !== metadata.id)
	{
		console.error(`Widget: id: ${metadata.id} and folder: ${folder} folder doesn't match`);
		success= false;
	}
	//slug/id lower case seperated by hyphens only
	var regexStringCheck = "^[a-z\d\-]*";
	if(!regexTester(metadata.slug,regexStringCheck)){
		console.error(`Widget id: ${metadata.id}: slug: ${metadata.slug}  doesn't match to only use lowercase, hyphens, and -`);
		success= false;
	}
	if(metadata.id.length > 30)
	{
		console.error(`Widget: id: ${metadata.id} shouldn't be longer than 30 characters`);	
		success= false;	
	}
	regexStringCheck = ".*-v\d{0,3}-\d{0,3}";
	if(regexTester(metadata.id,regexStringCheck))
	{
		console.error(`Widget: id: ${metadata.id}  shouldn't contain versions`);	
		success= false;	
	}
	regexStringCheck = "-widget";
	if(regexTester(metadata.id,regexStringCheck))
	{
		console.error(`Widget: id: ${metadata.id}  shouldn't contain -widget suffix`);	
		success= false;	
	}
	regexStringCheck = "^[a-z\d\-]*";
	if(!regexTester(metadata.id,regexStringCheck))
	{
		console.error(`Widget: id: ${metadata.id} doesn't match to only use lowercase, hyphens, and -`);	
		success= false;
	}
	//check widgetid for it to start with GEBusiness-[name]
	regexStringCheck = "^[a-z]*-.*";
	if(!regexTester(metadata.id,regexStringCheck))
	{
		console.error(`Widget: id: ${metadata.id} doesn't match to use GEBusiness-[name]`);	
		success= false;
	}
	//regex for slug
	regexStringCheck = "^[a-z\d\-]*v\d{0,3}-*\d{0,3}";
	if(!regexTester(metadata.slug,regexStringCheck)){
		console.error(`Widget id: ${metadata.id}: slug: ${metadata.slug} doesn't match to only use  [WidgetId]-v[x]-[y]`);
		success= false;
	}
	if(!success)
	{
		throw Error("Naming conventions are not being followed");
	}
	return success;
}
/**
 * [metaDataCheckVersion meta data check only for version files
 * @param  {String} fileContent text of metadata.json file
 * @return {Boolean}            returns true/false if it passed
 */
function metaDataCheckVersion(fileContent, masterFolder)
{
	if(validateJSON(fileContent))
	{
		var metadata = JSON.parse(fileContent);
		try
		{
			var fields = ["version","slug","author", "authorEmail", "properties"];
			shouldOnlyContain(metadata, fields);
		}
		catch(e)
		{
			console.error(`Widget failed metaDataCheck: ${masterFolder}`);
			return false;
		}
		return true;
	}
	else
	{
		console.error(`Doesn't contain a valid JSON object ${masterFolder}`);
		return false;
	}
}
/**
 * [metaDataCheck checks main metadata file and if everything formatted correctly]
 * @param  {String} fileContent text of metadata.json file
 * @param  {String} folder        folder name
 * @return {Boolean}            returns true/false if it passed
 */
function metaDataCheck(fileContent, folder) {
	
	if(validateJSON(fileContent))
	{
		var metadata = JSON.parse(fileContent);
		try
		{
			checkRequiredFields(metadata);
			namingConventionsCheck(metadata,folder);
			var fields = ["id", "title", "description", "tenants", "version", "slug", "category", "author", "type", "authorEmail", "properties", "isConfigurable"];
			shouldOnlyContain(metadata,fields);
		}
		catch(e)
		{
			errorOutput.push({
				id: metadata.id ,
				slug: metadata.slug ,
				title: metadata.title ,
				author: metadata.author ,
				email:  metadata.authorEmail,
				err: e+" ,look a the logs for more details" 
			});
			console.error(`Widget failed metaDataCheck: ${folder} \n err: ${e}`);
			console.log("\n");
			return false;
		}
		return true;
	}
	else
	{
		console.error(`Doesn't contain a valid JSON object ${folder}`);
		return false;
	}
}
/**
 * baseFolder goes through widget folder and its sub files
 * @param  {path} currentPath  path.join output of the path
 * @param  {String} masterFolder name of the file
 */
function baseFolder(currentPath, masterFolder) {
	var files = fs.readdirSync(currentPath);
	//console.log(`Checking the following widget: ${masterFolder}`);
	if(!files.includes("metadata.json"))
	{
		console.error( `Widget ${masterFolder} doesn't have metadata.json file.`);
		checkFailed = true;
		return false;
	}
    files.forEach( function( file, index ) 
    {
    	var fromPath = path.join( currentPath, file );
        let stat = fs.statSync(fromPath);
    	if( stat.isDirectory() )
    	{
    		versionFolderCheck(fromPath, file, masterFolder);
    	}
    	else if(file === "metadata.json")
    	{
    		var jsonString = fs.readFileSync(fromPath,'utf8');
    		if(!metaDataCheck(jsonString, masterFolder))
    		{
    			checkFailed = true;
    		}
    	}
    	else if(regexTester(file,".*.svg") && stat["size"]> 50000)
    	{
    		console.error( `File ${file} for ${masterFolder} is to big, max size 50KB`);
        	checkFailed = true;
    	}
    	 //*.html max 
    	else if(regexTester(file,".*.html") && stat["size"] > 500000)
    	{
    		console.error( `File ${file} for ${masterFolder} is to big, max size 500KB` );
        	checkFailed = true;
    	}
	        	
    });
}

/**
 * [baseFolder goes through version folder and checks files
 * @param  {path} currentPath  path.join output of the path
 * @param  {String} masterFolder name of the file
 */
function versionFolderCheck(currentPath, masterfile, masterFolder)
{
	var stat = fs.statSync(currentPath);
	if( !stat.isDirectory() )
	{
		return false;
	}
	var files = fs.readdirSync(currentPath);
	if(!files.includes("metadata.json"))
	{

		return false;
	}
    files.forEach( function( file, index ) 
    {
    	var fromPath = path.join( currentPath, file );
        let stat = fs.statSync(fromPath);
    	if(file === "metadata.json")
    	{
    		var jsonString = fs.readFileSync(fromPath,'utf8');
    		if(!metaDataCheckVersion(jsonString,masterFolder ))
    		{
    			checkFailed = true;
    		}
    	}
    	else if(regexTester(file,".*.svg") && stat["size"]> 50000)
    	{
    		console.error( `File ${file} for ${masterFolder} is to big, max size 50KB`);
        	checkFailed = true;
    	}
    	 //*.html max 
    	else if(regexTester(file,".*.html") && stat["size"] > 500000)
    	{
    		console.error( `File ${file} for ${masterFolder} is to big, max size 500KB` );
        	checkFailed = true;
    	}
	        	
    });
}
//converts array of objects to csv
function convertArrayOfObjectsToCSV(args) {  
    var result, ctr, keys, columnDelimiter, lineDelimiter, data;

    data = args.data || null;
    if (data == null || !data.length) {
        return null;
    }

    columnDelimiter = args.columnDelimiter || ',';
    lineDelimiter = args.lineDelimiter || '\n';

    keys = Object.keys(data[0]);

    result = '';
    result += keys.join(columnDelimiter);
    result += lineDelimiter;

    data.forEach(function(item) {
        ctr = 0;
        keys.forEach(function(key) {
            if (ctr > 0) result += columnDelimiter;

            result += item[key];
            ctr++;
        });
        result += lineDelimiter;
    });

    return result;
}
/**
 * [writeToFile create a csv file]
 * @param  {String} output csv formated string
 */
function writeToFile(output) {
	fs.writeFileSync("needTobeFixed.csv", output);
    console.log("Widgets that need to be fixed outputed to needTobeFixed.csv"); 
}

/**
 * [outputResults outputs the results]
 */
function outputResults() {
    if(checkFailed)
    {
    	 var csv = convertArrayOfObjectsToCSV({
            data: errorOutput
        });
    	writeToFile(csv);
    	console.error("****** One of the widgets failed the check")
    	process.exit(1);
    }
    else
    {
    	console.log("All widgets check out");
    }
}
var args = process.argv.slice(2);
var fields={};
/*
	params: 
		dir=./../dashboard-widgets/bin.     will go into specified dir
		singleDir=on   						will just go in specific dir and check metadata.json, image, and vulc file
 */
if(args.length > 0)
{
	args.forEach(function(val) {
		var tempArray = val.split("=");
		fields[tempArray[0]] = tempArray[1];
	})
}
if(fields.hasOwnProperty("dir"))
{
	currentPath = fields["dir"];
}
//iterate thriough directory
//check metadata.json
if(currentPath !== "" && !fields.hasOwnProperty("singleDir"))
{	
	//goes through main bin and goes through all widgets
	var files = fs.readdirSync(currentPath);
    files.forEach( function( file, index ) 
    {
    		if(ignoreList.length > 0 && ignoreList.includes(file))
    		{
    			console.log(`Ignore this file :${file}`);
    			return;
    		}
            // Make one pass and make the file complete
            var fromPath = path.join( currentPath, file );
            let stat = fs.statSync(fromPath);
            if( stat.isDirectory() )
            {
            	baseFolder(fromPath, file);
            }
    } );
    outputResults();
}
//if you only want to check a specific directory
else if(fields.hasOwnProperty("singleDir")){
	var file = path.basename(currentPath);
    let stat = fs.statSync(currentPath);
    if( stat.isDirectory() )
    {
    	baseFolder(currentPath, file);
    }
    outputResults();
}
else
{
	console.error("current path wasn't set");
}
