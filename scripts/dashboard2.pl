#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $time_stamp = `echo \$(date +"%a %F %r")`;
chomp ($time_stamp);

my $cf_user = $ARGV[0];
my $cf_pwd = $ARGV[1];

my $qa01_space_id="7057482e-d735-47f3-8c20-3a0c99837186";
my $dev01_space_id="db7d2aa9-9f50-4e46-b321-d7181752331d";
my $uat01_space_id="14568591-961d-42f8-b6f2-628c97c4e4fc";
my $perf01_space_id="cd98d78c-21bf-45d6-aa14-a4226b14c7c5";
my $demoprod_space_id="f73004e8-a449-4fca-bb72-d7c6524ed070";
my $demodev_space_id="b568f490-30f9-432a-b277-82303306b3a7";
my $prod_space_id="88d8a240-068b-43c7-9f27-1365cd4c5a22";
my $dev02_space_id="3ef76363-abd9-4a0a-b479-51c0e6ece072";
my $qa02_space_id="d1ed22a9-ddb8-4100-b786-719d441b4755";
my $demodev02_space_id="1bbc1c0a-3e50-4a4a-ab76-30ca2131ce04";

my %qa_hash1;
my %dev_hash1;
my %uat_hash1;
my %perf_hash1;
my %demoprod_hash1;
my %demodev_hash1;
my %prod_hash1;
my %dev02_hash1;
my %qa02_hash1;
my %demodev02_hash1;

my $hash_ref;
my $app_name;
my @dev_apps;
my $app_count = 1;

my $report_name = 'dashboard.html';

my $dev_bg_color;

# New variables
my @down_apps;
my $dev_ctr = 0;
my $qa_ctr = 0;
my $uat_ctr = 0;
my $perf_ctr = 0;
my $demoprod_ctr = 0;
my $demodev_ctr = 0;
my $prod_ctr = 0;
my $dev02_ctr = 0;
my $qa02_ctr = 0;
my $demodev02_ctr = 0;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o OGD_Development_USWest_01 -s qa01`;

$hash_ref = create_hash($qa01_space_id);
%qa_hash1 = %$hash_ref;

$hash_ref = create_hash($dev01_space_id);
%dev_hash1 = %$hash_ref;

$hash_ref = create_hash($uat01_space_id);
%uat_hash1 = %$hash_ref;

$hash_ref = create_hash($perf01_space_id);
%perf_hash1 = %$hash_ref;

$hash_ref = create_hash($dev02_space_id);
%dev02_hash1 = %$hash_ref;

$hash_ref = create_hash($qa02_space_id);
%qa02_hash1 = %$hash_ref;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "Oil\&Gas_Product_Demo" -s prod-ogd-current`;

$hash_ref = create_hash($demoprod_space_id);
%demoprod_hash1 = %$hash_ref;

$hash_ref = create_hash($demodev_space_id);
%demodev_hash1 = %$hash_ref;

$hash_ref = create_hash($demodev02_space_id);
%demodev02_hash1 = %$hash_ref;

`cf login -a https://api.system.aws-usw02-pr.ice.predix.io -u $cf_user -p $cf_pwd -o "intellistream_prod" -s prod`;

$hash_ref = create_hash($prod_space_id);
%prod_hash1 = %$hash_ref;

# Create HTML Report below

open (my $fh, '>', $report_name) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment dashboard</title>\n<body>\n";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"5\">IntelliStream environments dashboard</font> - Last run on $time_stamp PST<BR><a href=\"https\:\/\/ogd-dashboard-auth.run.aws-usw02-pr.ice.predix.io\" target=\"_blank\">Click here to visit Dashboard version 2 beta!</a></th></tr>\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th NOWRAP>Sr. No.</th><th>Application Name</th><th>DEV01</th><th>DEV02</th><th>QA01</th><th>QA02</th><th>UAT01</th><th>PERF01</th><th>DEMOPREPROD01</th><th>DEMODEV01</th><th>DEMODEV02</th><th>PROD</th></tr>\n";

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

    if (!defined $version_demodev)
    {
        $version_demodev = "Missing";
    }
    
    if (!defined $version_prod)
    {
        $version_prod = "Missing";
    }

    if (!defined $version_dev02)
    {
        $version_dev02 = "Missing";
    }

    if (!defined $version_qa02)
    {
        $version_qa02 = "Missing";
    }

    if (!defined $version_demodev02)
    {
        $version_demodev02 = "Missing";
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
        print $fh "<td NOWRAP BGCOLOR=\"$dev_hash1{$app_name}[5]\">Version: 1.0.0.$version_dev<BR>Instances running: $dev_hash1{$app_name}[3]/$dev_hash1{$app_name}[4]<BR>Route: $dev_hash1{$app_name}[2]</td>";

        if ($dev_hash1{$app_name}[5] eq "#ffa8af")
        {
            $down_apps[$dev_ctr][0] = $app_name.":"." $dev_hash1{$app_name}[3]/$dev_hash1{$app_name}[4]";
            $dev_ctr++;
        }

        if ($version_dev02 eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$dev02_hash1{$app_name}[5]\">Version: 1.0.0.$version_dev02<BR>Instances running: $dev02_hash1{$app_name}[3]/$dev02_hash1{$app_name}[4]<BR>Route: $dev02_hash1{$app_name}[2]</td>";

            if ($dev02_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$dev02_ctr][1] = $app_name.":"." $dev02_hash1{$app_name}[3]/$dev02_hash1{$app_name}[4]";
                $dev02_ctr++;
            }
        }

        if ($version_qa eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$qa_hash1{$app_name}[5]\">Version: 1.0.0.$version_qa<BR>Instances running: $qa_hash1{$app_name}[3]/$qa_hash1{$app_name}[4]<BR>Route: $qa_hash1{$app_name}[2]</td>";

            if ($qa_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$qa_ctr][2] = $app_name.":"." $qa_hash1{$app_name}[3]/$qa_hash1{$app_name}[4]";
                $qa_ctr++;
            }
        }

        if ($version_qa02 eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$qa02_hash1{$app_name}[5]\">Version: 1.0.0.$version_qa02<BR>Instances running: $qa02_hash1{$app_name}[3]/$qa02_hash1{$app_name}[4]<BR>Route: $qa02_hash1{$app_name}[2]</td>";

            if ($qa02_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$qa02_ctr][3] = $app_name.":"." $qa02_hash1{$app_name}[3]/$qa02_hash1{$app_name}[4]";
                $qa02_ctr++;
            }
        }
        
        if ($version_uat eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$uat_hash1{$app_name}[5]\">Version: 1.0.0.$version_uat<BR>Instances running: $uat_hash1{$app_name}[3]/$uat_hash1{$app_name}[4]<BR>Route: $uat_hash1{$app_name}[2]</td>";

            if ($uat_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$uat_ctr][4] = $app_name.":"." $uat_hash1{$app_name}[3]/$uat_hash1{$app_name}[4]";
                $uat_ctr++;
            }
        }

        if ($version_perf eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$perf_hash1{$app_name}[5]\">Version: 1.0.0.$version_perf<BR>Instances running: $perf_hash1{$app_name}[3]/$perf_hash1{$app_name}[4]<BR>Route: $perf_hash1{$app_name}[2]</td>";

            if ($perf_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$perf_ctr][5] = $app_name.":"." $perf_hash1{$app_name}[3]/$perf_hash1{$app_name}[4]";
                $perf_ctr++;
            }
        }
        
        if ($version_demoprod eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demoprod_hash1{$app_name}[5]\">Version: 1.0.0.$version_demoprod<BR>Instances running: $demoprod_hash1{$app_name}[3]/$demoprod_hash1{$app_name}[4]<BR>Route: $demoprod_hash1{$app_name}[2]</td>";

            if ($demoprod_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$demoprod_ctr][6] = $app_name.":"." $demoprod_hash1{$app_name}[3]/$demoprod_hash1{$app_name}[4]";
                $demoprod_ctr++;
            }
        }

        if ($version_demodev eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demodev_hash1{$app_name}[5]\">Version: 1.0.0.$version_demodev<BR>Instances running: $demodev_hash1{$app_name}[3]/$demodev_hash1{$app_name}[4]<BR>Route: $demodev_hash1{$app_name}[2]</td>";

            if($demodev_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$demodev_ctr][7] = $app_name.":"." $demodev_hash1{$app_name}[3]/$demodev_hash1{$app_name}[4]";
                $demodev_ctr++;
            }
        }

        if ($version_demodev02 eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td>";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$demodev02_hash1{$app_name}[5]\">Version: 1.0.0.$version_demodev02<BR>Instances running: $demodev02_hash1{$app_name}[3]/$demodev02_hash1{$app_name}[4]<BR>Route: $demodev02_hash1{$app_name}[2]</td>";

            if($demodev02_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$demodev02_ctr][8] = $app_name.":"." $demodev02_hash1{$app_name}[3]/$demodev02_hash1{$app_name}[4]";
                $demodev02_ctr++;
            }
        }

        if ($version_prod eq "Missing")
        {
            print $fh "<td NOWRAP>App is missing</td></tr>\n";
        }
        else
        {
            print $fh "<td NOWRAP BGCOLOR=\"$prod_hash1{$app_name}[5]\">Version: 1.0.0.$version_prod<BR>Instances running: $prod_hash1{$app_name}[3]/$prod_hash1{$app_name}[4]<BR>Route: $prod_hash1{$app_name}[2]</td></tr>\n";

            if ($prod_hash1{$app_name}[5] eq "#ffa8af")
            {
                $down_apps[$prod_ctr][9] = $app_name.":"." $prod_hash1{$app_name}[3]/$prod_hash1{$app_name}[4]";
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

# open (my $fh1, '>', $report1_name) or die "Could not create file.\n";

# print $fh1 "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment report</title>\n<body>\n";
# print $fh1 "<table border=\"0\">\n";
# print $fh1 "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"5\">IntelliStream environments report</font> - Last run on $time_stamp PST</th></tr>\n";
# print $fh1 "<tr bgcolor=\"#30aaf4\"><th>DEV01</th><th>QA01</th><th>UAT01</th><th>PERF01</th><th>DEMOPREPROD01</th><th>DEMODEV01</th><th>PROD</th></tr>\n";

# for my $i ( 0 .. $#down_apps ) 
# {
#     print $fh1 "<tr>";

# 	for my $j ( 0 .. $#{$down_apps[$i]} )
#     {
#         if (!defined $down_apps[$i][$j])
#         {
#             print $fh1 "<td></td>";
#         }
#         else
#         {
#             print $fh1 "<td NOWRAP bgcolor=\"#ffa8af\">$down_apps[$i][$j]</td>";
#         }
# 	}
#     print $fh1 "</tr>\n";
# }

# print $fh1 "</table>\n</body>\n</html>\n";
# close($fh1);

#print Dumper \@down_apps;

# 2nd outage report below

my $x1;
my $y1;
my $report2_name = "apps_down1.html";

open (my $fh2, '>', $report2_name) or die "Could not create file.\n";

print $fh2 "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment report</title>\n<body>\n";
print $fh2 "<table border=\"1\">\n";
print $fh2 "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"7\">IntelliStream services unavailability report</font> - Last run on $time_stamp PST</th></tr>\n";
print $fh2 "<tr bgcolor=\"#30aaf4\"><th><font size=\"5\">DEV01</th><th><font size=\"5\">DEV02</th><th><font size=\"5\">QA01</th><th><font size=\"5\">QA02</th><th><font size=\"5\">UAT01</th><th><font size=\"5\">PERF01</th><th><font size=\"5\">DEMOPREPROD01</th><th><font size=\"5\">DEMODEV01</th><th><font size=\"5\">DEMODEV02</th><th><font size=\"5\">PROD</th></tr>\n";

for my $i ( 0 .. $#down_apps ) 
{
    print $fh2 "<tr>";

	for my $j ( 0 .. 9 )
    {
        if (!defined $down_apps[$i][$j])
        {
            print $fh2 "<td></td>";
        }
        else
        {
            print $fh2 "<td NOWRAP bgcolor=\"#ff0000\"><font size=\"5\" color=\"white\">$down_apps[$i][$j]</td>";
        }
	}
    print $fh2 "</tr>\n";
}

print $fh2 "</table>\n</body>\n</html>\n";
close($fh2);

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
