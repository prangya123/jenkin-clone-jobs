#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];
my $env1 = $ARGV[2];
my $env2 = $ARGV[3];
my $qa01_space_id="7057482e-d735-47f3-8c20-3a0c99837186";
my $dev01_space_id="db7d2aa9-9f50-4e46-b321-d7181752331d";
my $uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
my $perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";
my $demoprod_space_id="f73004e8-a449-4fca-bb72-d7c6524ed070";
my $demodev_space_id="b568f490-30f9-432a-b277-82303306b3a7";
my $prod_space_id="88d8a240-068b-43c7-9f27-1365cd4c5a22";

my @temp_app_names;
my @temp_art_nums;

my %qa_hash1;
my %dev_hash1;
my %uat_hash1;
my %perf_hash1;
my %demoprod_hash1;
my %demodev_hash1;
my %prod_hash1;

my $app_name;
my @dev_apps;
my $app_count = 1;
my $bg_color;

my $report_name = 'env_comparison.html';

if ($env1 eq $env2)
{
    printf "Cannot compare same environments!\nQuitting!\n\n";
    exit 1;
}

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o OGD_Development_USWest_01 -s qa01`;

`cf curl "/v2/apps?q=space_guid:$qa01_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@qa_hash1{@temp_app_names} = @temp_art_nums;

`cf curl "/v2/apps?q=space_guid:$dev01_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@dev_hash1{@temp_app_names} = @temp_art_nums;

`cf curl "/v2/apps?q=space_guid:$uat01_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@uat_hash1{@temp_app_names} = @temp_art_nums;

`cf curl "/v2/apps?q=space_guid:$perf01_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@perf_hash1{@temp_app_names} = @temp_art_nums;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "Oil\&Gas_Product_Demo" -s prod-ogd-current`;

`cf curl "/v2/apps?q=space_guid:$demoprod_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@demoprod_hash1{@temp_app_names} = @temp_art_nums;

`cf curl "/v2/apps?q=space_guid:$demodev_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@demodev_hash1{@temp_app_names} = @temp_art_nums;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "intellistream_prod" -s prod`;

`cf curl "/v2/apps?q=space_guid:$prod_space_id\&results-per-page=100" > apps_list.json`;
@temp_app_names = `cat apps_list.json | jq -r ".resources[].entity.name"`;
@temp_art_nums = `cat apps_list.json | jq -r ".resources[].entity.environment_json.ARTIFACT_VERSION"`;
chomp (@temp_app_names);
chomp (@temp_art_nums);
@prod_hash1{@temp_app_names} = @temp_art_nums;

open (my $fh, '>', $report_name) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment dashboard</title>\n<body>\n";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th>Sr. No.</th><th>Application Name</th><th>$env1</th><th>$env2</th></tr>\n";

my $hash_ref;
my %hash1;
my %hash2;

if ($env1 eq "DEV01")
{
    $hash_ref = \%dev_hash1;
}
elsif ($env1 eq "QA01")
{
    $hash_ref = \%qa_hash1;
}
elsif ($env1 eq "UAT01")
{
    $hash_ref = \%uat_hash1;
}
elsif ($env1 eq "PERF01")
{
    $hash_ref = \%perf_hash1;
}
elsif ($env1 eq "DEMOPROD01")
{
    $hash_ref = \%demoprod_hash1;
}
elsif ($env1 eq "DEMODEV01")
{
    $hash_ref = \%demodev_hash1;
}
elsif ($env1 eq "PROD01")
{
    $hash_ref = \%prod_hash1;
}
else
{
    $hash_ref = \%dev_hash1;
}
%hash1 = %$hash_ref;

if ($env2 eq "DEV01")
{
    $hash_ref = \%dev_hash1;
}
elsif ($env2 eq "QA01")
{
    $hash_ref = \%qa_hash1;
}
elsif ($env2 eq "UAT01")
{
    $hash_ref = \%uat_hash1;
}
elsif ($env2 eq "PERF01")
{
    $hash_ref = \%perf_hash1;
}
elsif ($env2 eq "DEMOPROD01")
{
    $hash_ref = \%demoprod_hash1;
}
elsif ($env2 eq "DEMODEV01")
{
    $hash_ref = \%demodev_hash1;
}
elsif ($env2 eq "PROD01")
{
    $hash_ref = \%prod_hash1;
}
else
{
    $hash_ref = \%qa_hash1;
}
%hash2 = %$hash_ref;

@dev_apps = sort keys %hash1;
for $app_name (@dev_apps)
{
    my $version1 = $hash1{$app_name};
    my $version2 = $hash2{$app_name};

    if (!defined $version1)
    {
        $version1 = "App missing";
    }

    if (!defined $version2)
    {
        $version2 = "App missing";
    }

    if ($version1 ne $version2)
    {
        $bg_color = "#ffa8af";
    }
    else
    {
        $bg_color = "#e2f4ff";
    }
    
    if ($version1 ne "null")
    {
        print $fh "<tr BGCOLOR=\"$bg_color\"><td>$app_count</td><td>$app_name</td><td>$version1</td><td>$version2</td></tr>\n";
        $app_count++;
    }
    else
    {
        print "Not defined app is $app_name\n";
    }
}

print $fh "</table>\n</body>\n</html>\n";
close($fh);
