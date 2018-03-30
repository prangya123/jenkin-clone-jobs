#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];
my $env1 = $ARGV[2];

my $qa01_space_id="7057482e-d735-47f3-8c20-3a0c99837186";
my $qa01_org="OGD_Development_USWest_01";
my $qa01_space="qa01";

my $dev01_space_id="db7d2aa9-9f50-4e46-b321-d7181752331d";
my $dev01_org="OGD_Development_USWest_01";
my $dev01_space="dev01";

my $uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
my $uat01_org="OGD_Development_USWest_01";
my $uat01_space="uat01";

my $perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";
my $perf01_org="OGD_Development_USWest_01";
my $perf01_space="perf01";

my $demoprod_space_id="f73004e8-a449-4fca-bb72-d7c6524ed070";
my $demoprod_org="Oil\&Gas_Product_Demo";
my $demoprod_space="prod-ogd-current";

my $demodev_space_id="b568f490-30f9-432a-b277-82303306b3a7";
my $demodev_org="Oil\&Gas_Product_Demo";
my $demodev_space="dev-ogd-current";

my $prod_space_id="88d8a240-068b-43c7-9f27-1365cd4c5a22";
my $prod_org="intellistream_prod";
my $prod_space="prod";

my $dev02_space_id="3ef76363-abd9-4a0a-b479-51c0e6ece072";
my $dev02_org="OGD_Development_USWest_01";
my $dev02_space="dev02";

my $qa02_space_id="d1ed22a9-ddb8-4100-b786-719d441b4755";
my $qa02_org="OGD_Development_USWest_01";
my $qa02_space="qa02";

my $demodev02_space_id="1bbc1c0a-3e50-4a4a-ab76-30ca2131ce04";
my $demodev02_org="Oil\&Gas_Product_Demo";
my $demodev02_space="demodev02";

my $demoprod02_space_id="0bb3331e-65bc-4125-ade7-cf6878f46bcd";
my $demoprod02_org="Oil\&Gas_Product_Demo";
my $demoprod02_space="demoprod02";

my $bfx01_space_id="ae0ceb24-5dde-40b1-ad41-ee2fd6ee8764";
my $bfx01_org="OGD_Development_USWest_01";
my $bfx01_space="bfx01";

my $env1_space_id;
my $env1_org;
my $env1_space;

my %env1_hash1;


my @temp_app_names;
my @temp_art_nums;

my $app_name;
my @dev_apps;
my $app_count = 1;
my $bg_color;

if ($env1 eq "DEV01")
{
    $env1_space_id = $dev01_space_id;
    $env1_org = $dev01_org;
    $env1_space = $dev01_space;
}
elsif ($env1 eq "DEV02")
{
    $env1_space_id = $dev02_space_id;
    $env1_org = $dev02_org;
    $env1_space = $dev02_space;
}
elsif ($env1 eq "QA01")
{
    $env1_space_id = $qa01_space_id;
    $env1_org = $qa01_org;
    $env1_space = $qa01_space;
}
elsif ($env1 eq "QA02")
{
    $env1_space_id = $qa02_space_id;
    $env1_org = $qa02_org;
    $env1_space = $qa02_space;
}
elsif ($env1 eq "UAT01")
{
    $env1_space_id = $uat01_space_id;
    $env1_org = $uat01_org;
    $env1_space = $uat01_space;
}
elsif ($env1 eq "PERF01")
{
    $env1_space_id = $perf01_space_id;
    $env1_org = $perf01_org;
    $env1_space = $perf01_space;
}
elsif ($env1 eq "DEMOPROD01")
{
    $env1_space_id = $demoprod_space_id;
    $env1_org = $demoprod_org;
    $env1_space = $demoprod_space;
}
elsif ($env1 eq "DEMOPROD02")
{
    $env1_space_id = $demoprod02_space_id;
    $env1_org = $demoprod02_org;
    $env1_space = $demoprod02_space;
}
elsif ($env1 eq "DEMODEV01")
{
    $env1_space_id = $demodev_space_id;
    $env1_org = $demodev_org;
    $env1_space = $demodev_space;
}
elsif ($env1 eq "DEMODEV02")
{
    $env1_space_id = $demodev02_space_id;
    $env1_org = $demodev02_org;
    $env1_space = $demodev02_space;
}
elsif ($env1 eq "PROD01")
{
    $env1_space_id = $prod_space_id;
    $env1_org = $prod_org;
    $env1_space = $prod_space;
}
elsif ($env1 eq "BFX01")
{
    $env1_space_id = $bfx01_space_id;
    $env1_org = $bfx01_org;
    $env1_space = $bfx01_space;
}
else
{
    printf "ERROR: $env1 seems like a new environment, please update the script to include it.\nIf it is not a new environment, please file a defect.\nQuitting!\n\n";
    exit 1;
}

cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -o $env1_org -s $env1_space -p $cf_pwd
cf space $env1_space --guid
cf curl "/v2/apps?q=space_guid:$env1_space_id&results-per-page=100"
cf curl "/v2/apps?order-direction=asc&page=2&q=space_guid:$env1_space_id&results-per-page=100"
cf curl "/v2/apps?q=space_guid:$env1_space_id" |  jq -r '.resources[] | "\(.entity.name): \(.entity.environment_json.ARTIFACT_VERSION)"'
cf curl "/v2/apps?q=space_guid:$env1_space_id&results-per-page=100" |  jq -r '.resources[] | "\(.entity.name): \(.entity.environment_json.BUILD_NUMBER)"'
