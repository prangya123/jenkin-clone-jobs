#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $time_stamp = localtime;

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];

my $qa01_space_id="7057482e-d735-47f3-8c20-3a0c99837186";
my $dev01_space_id="db7d2aa9-9f50-4e46-b321-d7181752331d";
my $uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
my $perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";
my $demoprod_space_id="f73004e8-a449-4fca-bb72-d7c6524ed070";
my $demodev_space_id="b568f490-30f9-432a-b277-82303306b3a7";
my $prod_space_id="88d8a240-068b-43c7-9f27-1365cd4c5a22";

my %qa_hash1;
my %dev_hash1;
my %uat_hash1;
my %perf_hash1;
my %demoprod_hash1;
my %demodev_hash1;
my %prod_hash1;

my $hash_ref;
my $app_name;
my @dev_apps;
my $app_count = 1;

my $report_name = 'dashboard.html';

my $dev_bg_color;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o OGD_Development_USWest_01 -s qa01`;

$hash_ref = create_hash($qa01_space_id);
%qa_hash1 = %$hash_ref;

$hash_ref = create_hash($dev01_space_id);
%dev_hash1 = %$hash_ref;

$hash_ref = create_hash($uat01_space_id);
%uat_hash1 = %$hash_ref;

$hash_ref = create_hash($perf01_space_id);
%perf_hash1 = %$hash_ref;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "Oil\&Gas_Product_Demo" -s prod-ogd-current`;

$hash_ref = create_hash($demoprod_space_id);
%demoprod_hash1 = %$hash_ref;

$hash_ref = create_hash($demodev_space_id);
%demodev_hash1 = %$hash_ref;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "intellistream_prod" -s prod`;

$hash_ref = create_hash($prod_space_id);
%prod_hash1 = %$hash_ref;

# Create HTML Report below

open (my $fh, '>', $report_name) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment dashboard</title>\n<body>\n";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\">Artifact versions dashboard - Last run on $time_stamp</th></tr>\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th NOWRAP>Sr. No.</th><th>Application Name</th><th>DEV01</th><th>QA01</th><th>UAT01</th><th>PERF01</th><th>DEMOPREPROD01</th><th>DEMODEV01</th><th>PROD</th></tr>\n";

@dev_apps = sort keys %dev_hash1;
for $app_name (@dev_apps)
{
    my $version_dev = $dev_hash1{$app_name}[0];
    my $version_qa = $qa_hash1{$app_name}[0];
    my $version_uat = $uat_hash1{$app_name}[0];
    my $version_perf = $perf_hash1{$app_name}[0];
    my $version_demoprod = $demoprod_hash1{$app_name}[0];
    my $version_demodev = $demodev_hash1{$app_name}[0];
    my $version_prod = $prod_hash1{$app_name}[0];

    if (!defined $version_qa)
    {
        $version_qa = "Missing";
    }

    if (!defined $version_uat)
    {
        $version_uat = "Missing";
    }
    
    if (!defined $version_perf)
    {
        $version_perf = "Missing";
    }

    if (!defined $version_demoprod)
    {
        $version_demoprod = "Missing";
    }

    if (!defined $version_demodev)
    {
        $version_demodev = "Missing";
    }
    
    if (!defined $version_prod)
    {
        $version_prod = "Missing";
    }

    # if ($version_dev ne "null")
    # {
    #     print $fh "<tr BGCOLOR=\"#e2f4ff\"><td bgcolor=\"#30aaf4\">$app_count</td><td bgcolor=\"#30aaf4\">$app_name</td>";
    #     print $fh "<td title=\"https://$dev_hash1{$app_name}[2]\">$version_dev - $dev_hash1{$app_name}[1]</td>";
    #     print $fh "<td>$version_qa - $qa_hash1{$app_name}[1]<BR>https://$qa_hash1{$app_name}[2]</td>";
    #     print $fh "<td>$version_uat - $uat_hash1{$app_name}[1]<BR>$uat_hash1{$app_name}[2]</td>";
    #     print $fh "<td>$version_perf - $perf_hash1{$app_name}[1]<BR>$perf_hash1{$app_name}[2]</td>";
    #     print $fh "<td>$version_demoprod - $demoprod_hash1{$app_name}[1]<BR>$demoprod_hash1{$app_name}[2]</td>";
    #     print $fh "<td>$version_demodev - $demodev_hash1{$app_name}[1]<BR>$demodev_hash1{$app_name}[2]</td>";
    #     print $fh "<td>$version_prod - $prod_hash1{$app_name}[1]<BR>$prod_hash1{$app_name}[2]</td></tr>\n";
    #     $app_count++;
    # }

    if ($version_dev ne "null")
    {
        print $fh "<tr BGCOLOR=\"#e2f4ff\"><td NOWRAP bgcolor=\"#30aaf4\">$app_count</td><td NOWRAP bgcolor=\"#30aaf4\">$app_name</td>";
        print $fh "<td NOWRAP BGCOLOR=\"$dev_hash1{$app_name}[5]\">Version: $version_dev<BR>Instances: $dev_hash1{$app_name}[3]/$dev_hash1{$app_name}[4]<BR>Route: $dev_hash1{$app_name}[2]</td>";

        if ($version_qa eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$qa_hash1{$app_name}[5]\">Version: $version_qa<BR>Instances: $qa_hash1{$app_name}[3]/$qa_hash1{$app_name}[4]<BR>Route: $qa_hash1{$app_name}[2]</td>";
        }
        
        if ($version_uat eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$uat_hash1{$app_name}[5]\">Version: $version_uat<BR>Instances: $uat_hash1{$app_name}[3]/$uat_hash1{$app_name}[4]<BR>Route: $uat_hash1{$app_name}[2]</td>";
        }

        if ($version_perf eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$perf_hash1{$app_name}[5]\">Version: $version_perf<BR>Instances: $perf_hash1{$app_name}[3]/$perf_hash1{$app_name}[4]<BR>Route: $perf_hash1{$app_name}[2]</td>";
        }
        
        if ($version_demoprod eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demoprod_hash1{$app_name}[5]\">Version: $version_demoprod<BR>Instances: $demoprod_hash1{$app_name}[3]/$demoprod_hash1{$app_name}[4]<BR>Route: $demoprod_hash1{$app_name}[2]</td>";
        }

        if ($version_demodev eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demodev_hash1{$app_name}[5]\">Version: $version_demodev<BR>Instances: $demodev_hash1{$app_name}[3]/$demodev_hash1{$app_name}[4]<BR>Route: $demodev_hash1{$app_name}[2]</td>";
        }

        if ($version_prod eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$prod_hash1{$app_name}[5]\">Version: $version_prod<BR>Instances: $prod_hash1{$app_name}[3]/$prod_hash1{$app_name}[4]<BR>Route: $prod_hash1{$app_name}[2]</td></tr>\n";
        }

        $app_count++;
    }
    else
    {
        print "Not defined app is $app_name\n";
    }
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

    `cf curl "/v2/spaces/$sub_space/summary" > apps_list.json`;
    @temp_app_names = `cat apps_list.json | jq -r ".apps[].name"`;
    @temp_art_nums = `cat apps_list.json | jq -r ".apps[].environment_json.ARTIFACT_VERSION"`;
    @temp_app_state = `cat apps_list.json | jq -r ".apps[].state"`;
    @temp_running_instances = `cat apps_list.json | jq -r ".apps[].running_instances"`;
    @temp_total_instances = `cat apps_list.json | jq -r ".apps[].instances"`;
    $test_str = `cat apps_list.json | jq ".apps[].urls"`;
    $test_str =~ s/\[\]/NO_ROUTE/g;
    $test_str =~ s/\[|\]| |\"//g;
    $test_str =~ s/\n+/\n/g;
    @temp_app_route = split "\n", $test_str;
    shift @temp_app_route;
    chomp (@temp_app_names);
    chomp (@temp_art_nums);
    chomp (@temp_app_state);
    chomp (@temp_running_instances);
    chomp (@temp_total_instances);
    chomp (@temp_app_route);

    $i=0;
    foreach my $name1 (@temp_app_names) 
    {
        $sub_hash{$name1}[0] = $temp_art_nums[$i];
        $sub_hash{$name1}[1] = $temp_app_state[$i];
        $sub_hash{$name1}[2] = $temp_app_route[$i];
        $sub_hash{$name1}[3] = $temp_running_instances[$i];
        $sub_hash{$name1}[4] = $temp_total_instances[$i];

        if ($temp_running_instances[$i] ne $temp_total_instances[$i])
        {
            $sub_hash{$name1}[5]="#ffa8af";
        }
        else
        {
            $sub_hash{$name1}[5]="#e2f4ff";
        }

        $i++;
    }

    #print Dumper(\%sub_hash);
    return \%sub_hash;
}
