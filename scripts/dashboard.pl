#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];
my $qa01_space_id="7057482e-d735-47f3-8c20-3a0c99837186";
my $dev01_space_id="db7d2aa9-9f50-4e46-b321-d7181752331d";
my $uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
my $perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";

my @temp_app_names;
my @temp_art_nums;

my %qa_hash1;
my %dev_hash1;
my %uat_hash1;
my %perf_hash1;

my $app_name;
my @dev_apps;

my $report_name = 'dashboard.html';

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

open (my $fh, '>', $report_name) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment dashboard</title>\n<body>\n";
print $fh "<table border=\"1\">\n<tr>\n<th>Application Name</th><th>DEV01</th><th>QA01</th><th>UAT01</th><th>PERF01</th></tr>\n";

@dev_apps = keys %dev_hash1;
for $app_name (@dev_apps)
{
    my $version_dev = $dev_hash1{$app_name};
    my $version_qa = $qa_hash1{$app_name};
    my $version_uat = $uat_hash1{$app_name};
    my $version_perf = $perf_hash1{$app_name};

    if (!defined $version_qa)
    {
        $version_qa = "App missing";
    }

    if (!defined $version_uat)
    {
        $version_uat = "App missing";
    }
    
    if (!defined $version_perf)
    {
        $version_perf = "App missing";
    }

    if ($version_dev != "null")
    {
        print $fh "<tr><td>$app_name</td><td>$version_dev</td><td>$version_qa</td><td>$version_uat</td><td>$version_perf</td></tr>\n";
    }
    else
    {
        print "Not defined app is $app_name\n";
    }
}


print $fh "</table>\n</body>\n</html>\n";
close($fh);
