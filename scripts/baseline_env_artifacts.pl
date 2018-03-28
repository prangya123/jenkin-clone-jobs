#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $time_stamp = `echo \$(date +"%a %F %r")`;
chomp ($time_stamp);

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];
my $env1 = $ARGV[2];

my $qa01_space_id="7057482e-d735-47f3-8c20-3a0c99837186";
my $uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
my $perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";
my $demoprod_space_id="f73004e8-a449-4fca-bb72-d7c6524ed070";
my $prod_space_id="88d8a240-068b-43c7-9f27-1365cd4c5a22";
my $dev02_space_id="3ef76363-abd9-4a0a-b479-51c0e6ece072";
my $qa02_space_id="d1ed22a9-ddb8-4100-b786-719d441b4755";
my $demodev02_space_id="1bbc1c0a-3e50-4a4a-ab76-30ca2131ce04";

my %qa_hash1;
my %uat_hash1;
my %perf_hash1;
my %demoprod_hash1;
my %prod_hash1;
my %dev02_hash1;
my %qa02_hash1;
my %demodev02_hash1;

my $hash_ref;
my $app_name;
my @index_apps;
my $app_count = 1;

my $report_name = 'baselineEnv_artifacts.html';
my $baseline_arts = 'baselineEnv_artifacts.dat';

# New variables
my @down_apps;
my $qa_ctr = 0;
my $uat_ctr = 0;
my $perf_ctr = 0;
my $demoprod_ctr = 0;
my $prod_ctr = 0;
my $dev02_ctr = 0;
my $qa02_ctr = 0;
my $demodev02_ctr = 0;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o OGD_Development_USWest_01 -s qa01`;

$hash_ref = create_hash($qa01_space_id);
%qa_hash1 = %$hash_ref;

$hash_ref = create_hash($uat01_space_id);
%uat_hash1 = %$hash_ref;

$hash_ref = create_hash($perf01_space_id);
%perf_hash1 = %$hash_ref;

$hash_ref = create_hash($dev02_space_id);
%dev02_hash1 = %$hash_ref;

$hash_ref = create_hash($qa02_space_id);
%qa02_hash1 = %$hash_ref;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "Oil\&Gas_Product_Demo" -s demoprod02`;

$hash_ref = create_hash($demoprod_space_id);
%demoprod_hash1 = %$hash_ref;

$hash_ref = create_hash($demodev02_space_id);
%demodev02_hash1 = %$hash_ref;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "intellistream_prod" -s prod`;

$hash_ref = create_hash($prod_space_id);
%prod_hash1 = %$hash_ref;

# Create HTML Report below

open (my $fh, '>', $report_name) or die "Could not create file.\n";

#print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment dashboard</title>\n<body>\n";
#print $fh "<table border=\"1\">\n";
#print $fh "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"5\">IntelliStream environments dashboard</font> - Last run on $time_stamp PST<BR><a href=\"https\:\/\/ogd-dashboard-auth.run.aws-usw02-pr.ice.predix.io\" target=\"_blank\">Click here to visit Dashboard version 2 beta!</a><BR><a href=\"https\:\/\/ogddash.run.aws-usw02-pr.ice.predix.io\/widgets_dashboard_details.html\" target=\"_blank\">Click for widgets dashboard</a></th></tr>\n";
#print $fh "<tr bgcolor=\"#30aaf4\">\n<th NOWRAP>Sr. No.</th><th>Application Name</th><th>DEV02</th><th>QA01</th><th>QA02</th><th>UAT01</th><th>PERF01</th><th>DEMOPREPROD01</th><th>DEMODEV02</th><th>PROD</th></tr>\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>BaseLine Environment Artifacts</title>\n<body>\n";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th>Sr. No.</th><th>Application Name</th><th>$env1</th></tr>\n";
    
@index_apps = sort keys %dev02_hash1;
for $app_name (@index_apps)
{
    my $version_qa = $qa_hash1{$app_name}[0];
    my $version_uat = $uat_hash1{$app_name}[0];
    my $version_perf = $perf_hash1{$app_name}[0];
    my $version_demoprod = $demoprod_hash1{$app_name}[0];
    my $version_prod = $prod_hash1{$app_name}[0];
    my $version_dev02 = $dev02_hash1{$app_name}[0];
    my $version_qa02 = $qa02_hash1{$app_name}[0];
    my $version_demodev02 = $demodev02_hash1{$app_name}[0];

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
    
    if (!defined $version_prod)
    {
        $version_prod = "Missing";
    }

    if (!defined $version_qa02)
    {
        $version_qa02 = "Missing";
    }

    if (!defined $version_demodev02)
    {
        $version_demodev02 = "Missing";
    }

    if ($version_dev02 ne "null")
    {
        print $fh "<tr BGCOLOR=\"#e2f4ff\"><td NOWRAP bgcolor=\"#30aaf4\">$app_count</td><td NOWRAP bgcolor=\"#30aaf4\">$app_name</td>";
        print $fh "<td NOWRAP BGCOLOR=\"$dev02_hash1{$app_name}[5]\">Artifact: $version_dev02<BR>$dev02_hash1{$app_name}[1]:::$dev02_hash1{$app_name}[2]<BR>Route: $dev02_hash1{$app_name}[2]</td>";

        if ($dev02_hash1{$app_name}[5] eq "#ffa8af")
        {
            $down_apps[$dev02_ctr][0] = $app_name.":"." $dev02_hash1{$app_name}[3]/$dev02_hash1{$app_name}[4]";
            $dev02_ctr++;
        }

        if ($version_qa eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$qa_hash1{$app_name}[5]\">Artifact: $version_qa<BR>Instances running: $qa_hash1{$app_name}[3]/$qa_hash1{$app_name}[4]<BR>Route: $qa_hash1{$app_name}[2]</td>";

            if ($qa_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$qa_ctr][1] = $app_name.":"." $qa_hash1{$app_name}[3]/$qa_hash1{$app_name}[4]";
                $qa_ctr++;
            }
        }

        if ($version_qa02 eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$qa02_hash1{$app_name}[5]\">Artifact: $version_qa02<BR>Instances running: $qa02_hash1{$app_name}[3]/$qa02_hash1{$app_name}[4]<BR>Route: $qa02_hash1{$app_name}[2]</td>";

            if ($qa02_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$qa02_ctr][2] = $app_name.":"." $qa02_hash1{$app_name}[3]/$qa02_hash1{$app_name}[4]";
                $qa02_ctr++;
            }
        }
        
        if ($version_uat eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$uat_hash1{$app_name}[5]\">Artifact: $version_uat<BR>Instances running: $uat_hash1{$app_name}[3]/$uat_hash1{$app_name}[4]<BR>Route: $uat_hash1{$app_name}[2]</td>";

            if ($uat_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$uat_ctr][3] = $app_name.":"." $uat_hash1{$app_name}[3]/$uat_hash1{$app_name}[4]";
                $uat_ctr++;
            }
        }

        if ($version_perf eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$perf_hash1{$app_name}[5]\">Artifact: $version_perf<BR>Instances running: $perf_hash1{$app_name}[3]/$perf_hash1{$app_name}[4]<BR>Route: $perf_hash1{$app_name}[2]</td>";

            if ($perf_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$perf_ctr][4] = $app_name.":"." $perf_hash1{$app_name}[3]/$perf_hash1{$app_name}[4]";
                $perf_ctr++;
            }
        }
        
        if ($version_demoprod eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demoprod_hash1{$app_name}[5]\">Artifact: $version_demoprod<BR>Instances running: $demoprod_hash1{$app_name}[3]/$demoprod_hash1{$app_name}[4]<BR>Route: $demoprod_hash1{$app_name}[2]</td>";

            if ($demoprod_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$demoprod_ctr][5] = $app_name.":"." $demoprod_hash1{$app_name}[3]/$demoprod_hash1{$app_name}[4]";
                $demoprod_ctr++;
            }
        }

        if ($version_demodev02 eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demodev02_hash1{$app_name}[5]\">Artifact: $version_demodev02<BR>Instances running: $demodev02_hash1{$app_name}[3]/$demodev02_hash1{$app_name}[4]<BR>Route: $demodev02_hash1{$app_name}[2]</td>";

            if($demodev02_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$demodev02_ctr][6] = $app_name.":"." $demodev02_hash1{$app_name}[3]/$demodev02_hash1{$app_name}[4]";
                $demodev02_ctr++;
            }
        }

        if ($version_prod eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td></tr>\n";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$prod_hash1{$app_name}[5]\">Artifact: $version_prod<BR>Instances running: $prod_hash1{$app_name}[3]/$prod_hash1{$app_name}[4]<BR>Route: $prod_hash1{$app_name}[2]</td></tr>\n";

            if ($prod_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$prod_ctr][7] = $app_name.":"." $prod_hash1{$app_name}[3]/$prod_hash1{$app_name}[4]";
                $prod_ctr++;
            }
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
    $test_str = `cat apps_list.json | jq '.apps[]|"\\(.urls)"' | cut -d',' -f1`;
   # $test_str = `cat apps_list.json | jq ".apps[].urls"`;
   # $test_str =~ s/\[\]/NO_ROUTE/g;
   # $test_str =~ s/\[|\]| |\"//g;
   # $test_str =~ s/\n+/\n/g;
    $test_str =~ s/\[//g;
    $test_str =~ s/\\//g;
    $test_str =~ s/\"//g;
    $test_str =~ s/\]//g;
    
    @temp_app_route = split "\n", $test_str;
   # shift @temp_app_route;
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
