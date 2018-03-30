#!/bin/bash

cf_user = $ARGV[0];
cf_pwd = $ARGV[1];
env1 = $ARGV[2];

qa01_space_id = "7057482e-d735-47f3-8c20-3a0c99837186";
qa01_org = "OGD_Development_USWest_01";
qa01_space = "qa01";

dev01_space_id="db7d2aa9-9f50-4e46-b321-d7181752331d";
dev01_org="OGD_Development_USWest_01";
dev01_space="dev01";

uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
uat01_org="OGD_Development_USWest_01";
uat01_space="uat01";

perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";
perf01_org="OGD_Development_USWest_01";
perf01_space="perf01";

demoprod_space_id="f73004e8-a449-4fca-bb72-d7c6524ed070";
demoprod_org="Oil\&Gas_Product_Demo";
demoprod_space="prod-ogd-current";

demodev_space_id="b568f490-30f9-432a-b277-82303306b3a7";
demodev_org="Oil\&Gas_Product_Demo";
demodev_space="dev-ogd-current";

prod_space_id="88d8a240-068b-43c7-9f27-1365cd4c5a22";
prod_org="intellistream_prod";
prod_space="prod";

dev02_space_id="3ef76363-abd9-4a0a-b479-51c0e6ece072";
dev02_org="OGD_Development_USWest_01";
dev02_space="dev02";

qa02_space_id="d1ed22a9-ddb8-4100-b786-719d441b4755";
qa02_org="OGD_Development_USWest_01";
qa02_space="qa02";

demodev02_space_id="1bbc1c0a-3e50-4a4a-ab76-30ca2131ce04";
demodev02_org="Oil\&Gas_Product_Demo";
demodev02_space="demodev02";

demoprod02_space_id="0bb3331e-65bc-4125-ade7-cf6878f46bcd";
demoprod02_org="Oil\&Gas_Product_Demo";
demoprod02_space="demoprod02";

bfx01_space_id="ae0ceb24-5dde-40b1-ad41-ee2fd6ee8764";
bfx01_org="OGD_Development_USWest_01";
bfx01_space="bfx01";

env1_space_id=“”;
env1_org=“”;
env1_space=“”;

   if [[ $env` = *DEV01* ]]
    then
	 env1_space_id = $dev01_space_id;
   	 env1_org = $dev01_org;
   	 env1_space = $dev01_space;
    fi
   if [[ $env` = *DEV02* ]]
    then
	 env1_space_id = $dev02_space_id;
   	 env1_org = $dev02_org;
   	 env1_space = $dev02_space;
    fi
   if [[ $env` = *QA01* ]]
    then
	 env1_space_id = $qa01_space_id;
   	 env1_org = $qa01_org;
   	 env1_space = $qa01_space;
    fi
   if [[ $env` = *QA02* ]]
    then
	 env1_space_id = $qa02_space_id;
   	 env1_org = $qa02_org;
   	 env1_space = $qa02_space;
    fi
   if [[ $env` = *UAT01* ]]
    then
	 env1_space_id = $uat01_space_id;
   	 env1_org = $uat01_org;
   	 env1_space = $uat01_space;
    fi
   if [[ $env` = *UAT02* ]]
    then
	 env1_space_id = $uat02_space_id;
   	 env1_org = $uat02_org;
   	 env1_space = $uat02_space;
    fi
   if [[ $env` = *DEMOPROD01* ]]
    then
	 env1_space_id = $demoprod_space_id;
   	 env1_org = $demoprod_org;
   	 env1_space = $demoprod_space;
    fi
   if [[ $env` = *DEMOPROD02* ]]
    then
	 env1_space_id = $demoprod02_space_id;
   	 env1_org = $demoprod02_org;
   	 env1_space = $demoprod02_space;
    fi
   if [[ $env` = *DEMODEV01* ]]
    then
	 env1_space_id = $demodev01_space_id;
   	 env1_org = $demodev01_org;
   	 env1_space = $demodev01_space;
    fi
   if [[ $env` = *DEMODEV02* ]]
    then
	 env1_space_id = $demodev02_space_id;
   	 env1_org = $demodev02_org;
   	 env1_space = $demodev02_space;
    fi
   if [[ $env` = *PROD01* ]]
    then
	 env1_space_id = $prod_space_id;
   	 env1_org = $prod_org;
   	 env1_space = $prod_space;
    fi
   if [[ $env` = *BFX01* ]]
    then
	 env1_space_id = $bfx01_space_id;
   	 env1_org = $bfx01_org;
   	 env1_space = $bfx01_space;
    fi

cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u ${CFUSER} -o $env1_org -s $env1_space -p ${CFPSWD}
cf space $env1_space --guid
cf curl "/v2/apps?q=space_guid:$env1_space_id&results-per-page=100"
cf curl "/v2/apps?order-direction=asc&page=2&q=space_guid:$env1_space_id&results-per-page=100"
cf curl "/v2/apps?q=space_guid:$env1_space_id" |  jq -r '.resources[] | "\(.entity.name): \(.entity.environment_json.ARTIFACT_VERSION)"'
cf curl "/v2/apps?q=space_guid:$env1_space_id&results-per-page=100" |  jq -r '.resources[] | "\(.entity.name): \(.entity.environment_json.BUILD_NUMBER)"'
