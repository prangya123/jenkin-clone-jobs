#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $time_stamp = `echo \$(date +"%a %F %r")`;
chomp ($time_stamp);

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];

my $dev02_sbx_space_id="8af7f485-d7b5-4c65-b543-20926f07f774";
my $qa02_sbx_space_id="357b9319-3942-41ed-8efb-7aa257efa05e";
my $dd02_sbx_space_id="81028cf1-b5f7-43af-8643-8ff3b24ee557";
my $dp02_sbx_space_id="ea931220-1af1-4ae7-bb7b-d55cabcc4d7c";
my $bfx01_sbx_space_id="26067950-d794-4c8d-b788-b22a83c66c70";

my $dev02_analysis_sbx_space_id="82ce41e7-6441-449b-b8d5-aaf6507bd0d6";
my $qa02_analysis_sbx_space_id="3d138abc-383b-422d-828d-e6a30b4964ea";
my $dd02_analysis_sbx_space_id="2b62727f-4706-4aaf-bc60-963a3530b64a";
my $dp02_analysis_sbx_space_id="68ee9a18-8aac-45ab-b5e1-e64cbfcba020";
my $bfx01_analysis_sbx_space_id="d6540e95-76da-46a0-b4a6-9f8c6d90f35f";

my %dev02_hash;
my %qa02_hash;
my %dd02_hash;
my %dp02_hash;
my %bfx01_hash;

my %dev02_analysis_hash;
my %qa02_analysis_hash;
my %dd02_analysis_hash;
my %dp02_analysis_hash;
my %bfx01_analysis_hash;

my $hash_ref;
my $app_name;
my @dev_apps;
my $app_count = 1;
my $report_name = 'sbx_dashboard.html';

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o OGD_Development_USWest_01 -s dev02`;

$hash_ref = create_hash($dev02_sbx_space_id);
%dev02_hash = %$hash_ref;

$hash_ref = create_hash($dev02_analysis_sbx_space_id);
%dev02_analysis_hash = %$hash_ref;
%dev02_hash = (%dev02_hash, %dev02_analysis_hash);

$hash_ref = create_hash($qa02_sbx_space_id);
%qa02_hash = %$hash_ref;

$hash_ref = create_hash($qa02_analysis_sbx_space_id);
%qa02_analysis_hash = %$hash_ref;
%qa02_hash = (%qa02_hash, %qa02_analysis_hash);

$hash_ref = create_hash($bfx01_sbx_space_id);
%bfx01_hash = %$hash_ref;

$hash_ref = create_hash($bfx01_analysis_sbx_space_id);
%bfx01_analysis_hash = %$hash_ref;
%bfx01_hash = (%bfx01_hash, %bfx01_analysis_hash);

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o 'Oil&Gas_Product_Demo' -s demodev02`;

$hash_ref = create_hash($dd02_sbx_space_id);
%dd02_hash = %$hash_ref;

$hash_ref = create_hash($dd02_analysis_sbx_space_id);
%dd02_analysis_hash = %$hash_ref;
%dd02_hash = (%dd02_hash, %dd02_analysis_hash);

$hash_ref = create_hash($dp02_sbx_space_id);
%dp02_hash = %$hash_ref;

$hash_ref = create_hash($dp02_analysis_sbx_space_id);
%dp02_analysis_hash = %$hash_ref;
%dp02_hash = (%dp02_hash, %dp02_analysis_hash);

# Create HTML Report below

open (my $fh, '>', $report_name) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Sandbox apps dashboard</title>\n<body>\n";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"5\">Sandbox environments dashboard</font> - Last run on $time_stamp PST<BR></th></tr>\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th NOWRAP>Sr. No.</th><th>Application Name</th><th>DEV02</th><th>QA02</th><th>DEMODEV02</th><th>DEMOPROD02</th><th>BFX01</th></tr>\n";

@dev_apps = sort keys %dev02_hash;
for $app_name (@dev_apps)
{
    my $dev02_app = $dev02_hash{$app_name}[6];
    my $qa02_app = $qa02_hash{$app_name}[6];
    my $dd02_app = $dd02_hash{$app_name}[6];
    my $dp02_app = $dp02_hash{$app_name}[6];
    my $bfx01_app = $bfx01_hash{$app_name}[6];

    print $fh "<tr BGCOLOR=\"#e2f4ff\"><td NOWRAP bgcolor=\"#30aaf4\">$app_count</td><td NOWRAP bgcolor=\"#30aaf4\">$app_name</td>";
    print $fh "<td NOWRAP BGCOLOR=\"$dev02_hash{$app_name}[5]\">$dev02_app <BR>Version: 1.0.0.$dev02_hash{$app_name}[0]<BR>Instances running: $dev02_hash{$app_name}[3]/$dev02_hash{$app_name}[4]<BR>Route: $dev02_hash{$app_name}[2]</td>";
    print $fh "<td NOWRAP BGCOLOR=\"$qa02_hash{$app_name}[5]\">$qa02_app <BR>Version: 1.0.0.$qa02_hash{$app_name}[0]<BR>Instances running: $qa02_hash{$app_name}[3]/$qa02_hash{$app_name}[4]<BR>Route: $qa02_hash{$app_name}[2]</td>";
    print $fh "<td NOWRAP BGCOLOR=\"$dd02_hash{$app_name}[5]\">$dd02_app <BR>Version: 1.0.0.$dd02_hash{$app_name}[0]<BR>Instances running: $dd02_hash{$app_name}[3]/$dd02_hash{$app_name}[4]<BR>Route: $dd02_hash{$app_name}[2]</td>";
    print $fh "<td NOWRAP BGCOLOR=\"$dp02_hash{$app_name}[5]\">$dp02_app <BR>Version: 1.0.0.$dp02_hash{$app_name}[0]<BR>Instances running: $dp02_hash{$app_name}[3]/$dp02_hash{$app_name}[4]<BR>Route: $dp02_hash{$app_name}[2]</td>";
    print $fh "<td NOWRAP BGCOLOR=\"$bfx01_hash{$app_name}[5]\">$bfx01_app <BR>Version: 1.0.0.$bfx01_hash{$app_name}[0]<BR>Instances running: $bfx01_hash{$app_name}[3]/$bfx01_hash{$app_name}[4]<BR>Route: $bfx01_hash{$app_name}[2]</td></tr>";

    $app_count++;
}

print $fh "</table>\n</body>\n</html>\n";
close($fh);

## SUBROUTINES BELOW

sub create_hash
{
    my $sub_space = shift;

    my %sub_hash;
    my @temp_app_names;
    my @temp_art_nums;
    my @temp_app_state;
    my @temp_app_route;
    my @temp_running_instances;
    my @temp_total_instances;
    my $test_str;
    my $i;
    my $app_name;

    `cf curl "/v2/spaces/$sub_space/summary" > apps_list.json`;
    @temp_app_names = `cat apps_list.json | jq -r ".apps[].name"`;
    @temp_art_nums = `cat apps_list.json | jq -r ".apps[].environment_json.ARTIFACT_VERSION"`;
    @temp_app_state = `cat apps_list.json | jq -r ".apps[].state"`;
    @temp_running_instances = `cat apps_list.json | jq -r ".apps[].running_instances"`;
    @temp_total_instances = `cat apps_list.json | jq -r ".apps[].instances"`;
    $test_str = `cat apps_list.json | jq '.apps[]|"\\(.urls)"' | cut -d',' -f1`;
    $test_str =~ s/\[//g;
    $test_str =~ s/\\//g;
    $test_str =~ s/\"//g;
    $test_str =~ s/\]//g;
    
    @temp_app_route = split "\n", $test_str;
    chomp (@temp_app_names);
    chomp (@temp_art_nums);
    chomp (@temp_app_state);
    chomp (@temp_running_instances);
    chomp (@temp_total_instances);
    chomp (@temp_app_route);

    $i=0;
    foreach my $name1 (@temp_app_names) 
    {
        if (index ($name1, "data-access-layer") != -1)
        {
            $app_name = "DAL";
        }
        elsif (index ($name1, "dashboard-ui") != -1)
        {
            $app_name = "DASHBOARD";
        }
        elsif (index ($name1, "widget-repo-service") != -1)
        {
            $app_name = "WRS";
        }
        elsif (index ($name1, "analysis-ui") != -1)
        {
            $app_name = "ANALYSIS";
        }
        else
        {
            printf "\n$name1 - UNIDENTIFIED APP!!\n\n";
        }

        $sub_hash{$app_name}[0] = $temp_art_nums[$i];
        $sub_hash{$app_name}[1] = $temp_app_state[$i];
        $sub_hash{$app_name}[2] = $temp_app_route[$i];
        $sub_hash{$app_name}[3] = $temp_running_instances[$i];
        $sub_hash{$app_name}[4] = $temp_total_instances[$i];

        if ($temp_running_instances[$i] ne $temp_total_instances[$i])
        {
            $sub_hash{$app_name}[5]="#ffa8af";
        }
        else
        {
            $sub_hash{$app_name}[5]="#e2f4ff";
        }

        $sub_hash{$app_name}[6] = $name1;
        $i++;
    }

#    print Dumper(\%sub_hash);
    return \%sub_hash;
}
