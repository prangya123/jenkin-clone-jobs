#!/usr/bin/perl
#
# ===================================================================
# Usage:            perl uat_history.pl CF_USER CF_PWD
# Purpose:          Script to generate a history of the apps availablity in the UAT01 space
# Parameters:       CF_USER CF_PWD
# Called From:      N/A
# Author:           Sufyan Farooqi
# ===================================================================


use strict;
use warnings;
use Data::Dumper qw(Dumper);

if (($#ARGV + 1) != 2)
{
    printf "Usage: uat_hostory.pl CF_USER CF_PASSWORD\n";
    exit;
}

my $username = $ARGV[0];
my $pwd = $ARGV[1];

my $api_url = "https://api.system.aws-usw02-pr.ice.predix.io";
my $org = "OGD_Development_USWest_01";
my $space ="uat01";

my $ret;
my @arr_apps;
my %hash_apps;

my $curr_date = `date +%m/%d/%Y" "%l:%M:%S" "%p`;
my $output_file = "uat_report.html";
my $lines;
my $pos;
my $temp_str;
my $app;

my @app_names_array = ('alertgeneration','alerttemplate','apm-docmanager-upstream','apm-docmanager-upstream-uat01','apmonshore-eventhub-publisher',
                        'apmonshore-reducertorque-service','apmonshore-reducertorque-subscriber','apmonshore-sitecommerror','asset-management-upstream',
                        'cardmicroservice','config-generator','docmanager-service','downholemicroservice','dynacard-mediator','equipmentcatalog',
                        'esp-model-upstream','eventhub-roadpumpoptimization','eventhub-subscriber-timeseries','gradient-service-integration',
                        'ipr-service-integration','og-dap-gateway-config','og-dap-gateway-services','operator-token','patternmatchingservice',
                        'pg-studio','problemcardmicroservice','pumpcurve-service','rls-analysis-upstream','rodpumpvelocity','rodstressmicroservice',
                        'rodstressmicroserviceuiinput','rodstressuioutputmicroservice','structure-loading-subscriber','well-model','well-state-evaluator',
                        'wellcommissioning');

chomp ($curr_date);

`cf login -a $api_url -u $username -p $pwd -o $org -s $space`;
@arr_apps = `cf a`;
chomp (@arr_apps);

foreach my $i (4 .. $#arr_apps) 
{
    my ($name, $stat) = (split /\s* \s*/, $arr_apps[$i])[0, 2];
	$hash_apps{$name} = $stat;
}

foreach $app (@app_names_array)
{
    my $stat1 = $hash_apps{$app};
    if ($stat1 =~ /0\//)
    {
        $hash_apps{$app} = "DOWN";
    }
    else
    {
        $hash_apps{$app} = "UP";
    }
}

open OUT_FILE, $output_file or die "Could not open '$output_file' $!\n";
$lines = do {local $/; <OUT_FILE>};
close (OUT_FILE);

$pos = index($lines, "<tr style=\"white-space:nowrap\">");
$temp_str = "<tr style=\"white-space:nowrap\">\n";

#Add timestamp to string
$temp_str = $temp_str . "<td align=\"center\">$curr_date</td>\n";

#Traverse the hash, create each html row and keep adding to string

foreach $app (@app_names_array)
{
    my $one_row;
    my $stat2 = $hash_apps{$app};
    if($stat2 eq "DOWN")
    {
        $one_row = "<td align=\"center\" bgcolor=\"#FF0000\">$stat2</td>\n";
    }
    else
    {
        $one_row = "<td align=\"center\">$stat2</td>\n";
    }
    $temp_str = $temp_str . $one_row;
}

# End the row
$temp_str = $temp_str . "</tr>\n";

# Insert the string in the file and DONE
my $new_str = substr $lines, 0, $pos-1;
$new_str = $new_str . $temp_str;
$new_str = $new_str . substr $lines, $pos; 

open OUT_FILE, ">", $output_file or die "Can't create < '$output_file' $!\n";
print OUT_FILE $new_str;
close (OUT_FILE);
