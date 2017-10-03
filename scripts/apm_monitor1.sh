#!/bin/bash

function getToken
{
    local UAA_URL=$1
    local AUTH_PASSED=$2
	#get token
	local token=$(curl -sX POST \
	$UAA_URL \
	-H 'authorization: Basic '$AUTH_PASSED \
	-H 'cache-control: no-cache' \
	-H 'content-type: application/x-www-form-urlencoded')

	#jq 
	#https://github.com/stedolan/jq/wiki/Installation
	echo $token | jq -r '.access_token'
}

function getRCStatus
{
    local url_passed=$1
    local ret1=$(curl -sX GET \
    $url_passed \
    -H 'authorization: Bearer '$RC_TOKEN \
	-H 'cache-control: no-cache' \
    -H 'tenant: 1f7a22b1-72e1-4915-94db-ff623fa2002e')

    echo $ret1 | jq -r '.status'
}

function getPPStatus
{
    local url_passed=$1
    local ret1=$(curl -sX GET \
    $url_passed \
    -H 'authorization: Bearer '$PP_TOKEN \
	-H 'cache-control: no-cache' \
    -H 'tenant: 75eaec32-a802-4c7b-9f70-b11efd06ced4')

    echo $ret1 | jq -r '.status'
}

function getProdStatus
{
    local url_passed=$1
    local ret1=$(curl -sX GET \
    $url_passed \
    -H 'authorization: Bearer '$PROD_TOKEN \
	-H 'cache-control: no-cache' \
    -H 'tenant: b7875037-e278-43d3-9f9f-8b624b19ba8d')

    echo $ret1 | jq -r '.status'
}


# RC URLs:
RC_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd"
RC_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo="
RC_ASSET_URL="https://apm-asset-svc-rc.int-app.aws-usw02-pr.predix.io/system_status"
RC_TS_URL="https://apm-timeseries-query-svc-rc.int-app.aws-usw02-pr.predix.io/system_status"
RC_STUF_URL="https://users-stuf-stufrc.apm.aws-usw02-pr.predix.io/system_status"

# PREPROD URLs:
PP_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd"
PP_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo="
PP_ASSET_URL="https://apm-asset-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/system_status"
PP_TS_URL="https://apm-timeseries-query-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/system_status"
PP_STUF_URL="https://users-stuf-stufprod.apm.aws-usw02-pr.predix.io/system_status"

# PROD URLS:
PROD_UAA="https://d1e53858-2903-4c21-86c0-95edc7a5cef2.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.57e72dd3-6f9e-4931-b4bc-cd04eaaff3e3.1f7dbe12-2372-439e-8104-06a5f4098ec9&grant_type=password&username=FuncUser01&password=Pa55w0rd"
PROD_AUTHORIZATION="aW5nZXN0b3IuNTdlNzJkZDMtNmY5ZS00OTMxLWI0YmMtY2QwNGVhYWZmM2UzLjFmN2RiZTEyLTIzNzItNDM5ZS04MTA0LTA2YTVmNDA5OGVjOTo="
PROD_ASSET_URL="https://apm-asset-svc-prod.app-api.aws-usw02-pr.predix.io/system_status"
PROD_TS_URL="https://apm-timeseries-query-svc-prod.app-api.aws-usw02-pr.predix.io/system_status"
PROD_STUF_URL="https://users-stuf-stufprod.apm.aws-usw02-pr.predix.io/system_status"

# RC CALLS BELOW

if [[ -z "$RC_TOKEN" ]]; then
	RC_TOKEN=$(getToken $RC_UAA $RC_AUTHORIZATION)
fi

# Check if we got the token back, if not, then error out and quit
if [[ -z "$RC_TOKEN" ]]; then
	echo ERROR - Could not get RC token, value is $RC_TOKEN
	exit 1
fi

RC_UAA_STATUS="UP"
echo UAA in RC is $RC_UAA_STATUS

RC_TS_STATUS=$(getRCStatus $RC_TS_URL)
echo Timseries service in RC is $RC_TS_STATUS

RC_ASSET_STATUS=$(getRCStatus $RC_ASSET_URL)
echo Asset service in RC is $RC_ASSET_STATUS

RC_STUF_STATUS=$(getRCStatus $RC_STUF_URL)
echo STUF service in RC is $RC_STUF_STATUS

# PREPROD CALLS BELOW

if [[ -z "$PP_TOKEN" ]]; then
	PP_TOKEN=$(getToken $PP_UAA $PP_AUTHORIZATION)
fi

# Check if we got the token back, if not, then error out and quit
if [[ -z "$PP_TOKEN" ]]; then
	echo ERROR - Could not get PREPROD token
	exit 1
fi

PP_UAA_STATUS="UP"
echo UAA in PREPROD is $PP_UAA_STATUS

PP_TS_STATUS=$(getPPStatus $PP_TS_URL)
echo Timseries service in PREPROD is $PP_TS_STATUS

PP_ASSET_STATUS=$(getPPStatus $PP_ASSET_URL)
echo Asset service in PREPROD is $PP_ASSET_STATUS

PP_STUF_STATUS=$(getPPStatus $PP_STUF_URL)
echo STUF service in PREPROD is $PP_STUF_STATUS

# PROD CALLS BELOW

if [[ -z "$PROD_TOKEN" ]]; then
	PROD_TOKEN=$(getToken $PROD_UAA $PROD_AUTHORIZATION)
fi

# Check if we got the token back, if not, then error out and quit
if [[ -z "$PROD_TOKEN" ]]; then
	echo ERROR - Could not get PROD token
	exit 1
fi

PROD_UAA_STATUS="UP"
echo UAA in PROD is $PROD_UAA_STATUS

PROD_TS_STATUS=$(getProdStatus $PROD_TS_URL)
echo Timseries service in PROD is $PROD_TS_STATUS

PROD_ASSET_STATUS=$(getProdStatus $PROD_ASSET_URL)
echo Asset service in PROD is $PROD_ASSET_STATUS

PROD_STUF_STATUS=$(getProdStatus $PROD_STUF_URL)
echo STUF service in PROD is $PROD_STUF_STATUS

# GENERATE HTML BELOW

echo "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>APM dashboard</title><body>" > apm_dashboard.html
echo "<table border=\"1\">"  >> apm_dashboard.html
echo "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"center\"><font size=\"7\">APM Endpoints availability</font></th></tr>" >> apm_dashboard.html
echo "<tr bgcolor=\"#30aaf4\"><th NOWRAP><font size=\"5\">End Point</th><th NOWRAP><font size=\"5\">RC Environment</th><th NOWRAP><font size=\"5\">PreProd Environment</th><th NOWRAP><font size=\"5\">Production Environment</th></tr>" >> apm_dashboard.html

if [ $RC_UAA_STATUS = "UP" ]; then
	col1="#00FF00"
else
	col1="#FF0000"
	RC_UAA_STATUS="DOWN"
fi

if [ $PP_UAA_STATUS = "UP" ]; then
	col2="#00FF00"
else
	col2="#FF0000"
	PP_UAA_STATUS="DOWN"
fi

if [ $PROD_UAA_STATUS = "UP" ]; then
	col3="#00FF00"
else
	col3="#FF0000"
	PROD_UAA_STATUS="DOWN"
fi

echo "<tr bgcolor=\"#30aaf4\"><td NOWRAP><font size=\"5\">UAA</td><td bgcolor=\"$col1\"><font size=\"5\">$RC_UAA_STATUS</td><td bgcolor=\"$col2\"><font size=\"5\">$PP_UAA_STATUS</td><td bgcolor=\"$col3\"><font size=\"5\">$PROD_UAA_STATUS</td></tr>" >> apm_dashboard.html

if [ $RC_TS_STATUS = "UP" ]; then
	col1="#00FF00"
else
	col1="#FF0000"
	RC_TS_STATUS="DOWN"
fi

if [ $PP_TS_STATUS = "UP" ]; then
	col2="#00FF00"
else
	col2="#FF0000"
	PP_TS_STATUS="DOWN"
fi

if [ $PROD_TS_STATUS = "UP" ]; then
	col3="#00FF00"
else
	col3="#FF0000"
	PROD_TS_STATUS="DOWN"
fi

echo "<tr bgcolor=\"#30aaf4\"><td NOWRAP><font size=\"5\">Time Series</td><td bgcolor=\"$col1\"><font size=\"5\">$RC_TS_STATUS</td><td bgcolor=\"$col2\"><font size=\"5\">$PP_TS_STATUS</td><td bgcolor=\"$col3\"><font size=\"5\">$PROD_TS_STATUS</td></tr>" >> apm_dashboard.html

if [ $RC_ASSET_STATUS = "UP" ]; then
	col1="#00FF00"
else
	col1="#FF0000"
	RC_ASSET_STATUS="DOWN"
fi

if [ $PP_ASSET_STATUS = "UP" ]; then
	col2="#00FF00"
else
	col2="#FF0000"
	PP_ASSET_STATUS="DOWN"
fi

if [ $PROD_ASSET_STATUS = "UP" ]; then
	col3="#00FF00"
else
	col3="#FF0000"
	PROD_ASSET_STATUS="DOWN"
fi

echo "<tr bgcolor=\"#30aaf4\"><td NOWRAP><font size=\"5\">Asset</td><td bgcolor=\"$col1\"><font size=\"5\">$RC_ASSET_STATUS</td><td bgcolor=\"$col2\"><font size=\"5\">$PP_ASSET_STATUS</td><td bgcolor=\"$col3\"><font size=\"5\">$PROD_ASSET_STATUS</td></tr>" >> apm_dashboard.html

if [ $RC_STUF_STATUS = "UP" ]; then
	col1="#00FF00"
else
	col1="#FF0000"
	RC_STUF_STATUS="DOWN"
fi

if [ $PP_STUF_STATUS = "UP" ]; then
	col2="#00FF00"
else
	col2="#FF0000"
	PP_STUF_STATUS="DOWN"
fi

if [ $PROD_STUF_STATUS = "UP" ]; then
	col3="#00FF00"
else
	col3="#FF0000"
	PROD_STUF_STATUS="DOWN"
fi

echo "<tr bgcolor=\"#30aaf4\"><td NOWRAP><font size=\"5\">STUF</td><td bgcolor=\"$col1\"><font size=\"5\">$RC_STUF_STATUS</td><td bgcolor=\"$col2\"><font size=\"5\">$PP_STUF_STATUS</td><td bgcolor=\"$col3\"><font size=\"5\">$PROD_STUF_STATUS</td></tr>" >> apm_dashboard.html

echo "</table></body></html>" >> apm_dashboard.html

#echo RC RESULTS BELOW
#echo UAA in RC is $RC_UAA_STATUS
#echo Timseries service in RC is $RC_TS_STATUS
#echo Asset service in RC is $RC_ASSET_STATUS
#echo STUF service in RC is $RC_STUF_STATUS

