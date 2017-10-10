#!/usr/bin/perl
use warnings;
use strict;
use JSON::PP;
use Data::Dumper qw(Dumper);

my $time_stamp = `echo \$(date +"%a %F %r")`;

my $rc_report = "apm_rc.html";
my $pp_report = "apm_pp.html";
my $prod_report = "apm_prod.html";

my $RC_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $RC_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo=";
my $RC_ASSET_URL="https://apm-asset-svc-rc.int-app.aws-usw02-pr.predix.io/system_status";
my $RC_TS_URL="https://apm-timeseries-query-svc-rc.int-app.aws-usw02-pr.predix.io/system_status";
my $RC_STUF_URL="https://users-stuf-stufrc.apm.aws-usw02-pr.predix.io/system_status";
my $RC_TENANT="1f7a22b1-72e1-4915-94db-ff623fa2002e";

my $PP_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $PP_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $PP_ASSET_URL="https://apm-asset-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/system_status";
my $PP_TS_URL="https://apm-timeseries-query-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/system_status";
my $PP_STUF_URL="https://users-stuf-stufprod.apm.aws-usw02-pr.predix.io/system_status";
my $PP_TENANT="75eaec32-a802-4c7b-9f70-b11efd06ced4";

my $PROD_UAA="https://d1e53858-2903-4c21-86c0-95edc7a5cef2.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.57e72dd3-6f9e-4931-b4bc-cd04eaaff3e3.1f7dbe12-2372-439e-8104-06a5f4098ec9&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $PROD_AUTHORIZATION="aW5nZXN0b3IuNTdlNzJkZDMtNmY5ZS00OTMxLWI0YmMtY2QwNGVhYWZmM2UzLjFmN2RiZTEyLTIzNzItNDM5ZS04MTA0LTA2YTVmNDA5OGVjOTo=";
my $PROD_ASSET_URL="https://apm-asset-svc-prod.app-api.aws-usw02-pr.predix.io/system_status";
my $PROD_TS_URL="https://apm-timeseries-query-svc-prod.app-api.aws-usw02-pr.predix.io/system_status";
my $PROD_STUF_URL="https://users-stuf-stufprod.apm.aws-usw02-pr.predix.io/system_status";
my $PROD_TENANT="b7875037-e278-43d3-9f9f-8b624b19ba8d";

my $rc_uaa_status;
my $rc_asset_status;
my $rc_ts_status;
my $rc_stuf_status;
my $RC_TOKEN;
my $rc_html_line;

my $pp_uaa_status;
my $pp_asset_status;
my $pp_ts_status;
my $pp_stuf_status;
my $PP_TOKEN;
my $pp_html_line;

my $prod_uaa_status;
my $prod_asset_status;
my $prod_ts_status;
my $prod_stuf_status;
my $PROD_TOKEN;
my $prod_html_line;

chomp ($time_stamp);

#RC HERE
$RC_TOKEN = get_token($RC_UAA, $RC_AUTHORIZATION);

if ($RC_TOKEN eq "")
{
    die " could not get RC token!";
}

$rc_uaa_status = "UP";
$rc_asset_status = get_status($RC_ASSET_URL, $RC_TOKEN, $RC_TENANT);
$rc_ts_status = get_status($RC_TS_URL, $RC_TOKEN, $RC_TENANT);
$rc_stuf_status = get_status($RC_STUF_URL, $RC_TOKEN, $RC_TENANT);
$rc_html_line = generate_line($time_stamp, $rc_uaa_status, $rc_ts_status, $rc_asset_status, $rc_stuf_status);
insert_line ($rc_html_line, $rc_report);

# <tr bgcolor="#30aaf4"><td NOWRAP>Fri 2017-10-06 03:40:18 PM PST</td><td bgcolor="#00FF00">UP</td><td bgcolor="#00FF00">UP</td><td bgcolor="#00FF00">UP</td><td bgcolor="#00FF00">UP</td></tr>

printf "RC UAA STATUS IS $rc_uaa_status\n";
printf "RC ASSET STATUS IS $rc_asset_status\n";
printf "RC TS STATUS IS $rc_ts_status\n";
printf "RC STUF STATUS IS $rc_stuf_status\n";

#PREPROD HERE
$PP_TOKEN = get_token($PP_UAA, $PP_AUTHORIZATION);

if ($PP_TOKEN eq "")
{
    die " could not get PP token!";
}

$pp_uaa_status = "UP";
$pp_asset_status = get_status($PP_ASSET_URL, $PP_TOKEN, $PP_TENANT);
$pp_ts_status = get_status($PP_TS_URL, $PP_TOKEN, $PP_TENANT);
$pp_stuf_status = get_status($PP_STUF_URL, $PP_TOKEN, $PP_TENANT);
$pp_html_line = generate_line($time_stamp, $pp_uaa_status, $pp_ts_status, $pp_asset_status, $pp_stuf_status);
insert_line ($pp_html_line, $pp_report);

printf "PP UAA STATUS IS $pp_uaa_status\n";
printf "PP ASSET STATUS IS $pp_asset_status\n";
printf "PP TS STATUS IS $pp_ts_status\n";
printf "PP STUF STATUS IS $pp_stuf_status\n";

#PROD HERE
$PROD_TOKEN = get_token($PROD_UAA, $PROD_AUTHORIZATION);

if ($PROD_TOKEN eq "")
{
    die " could not get PROD token!";
}

$prod_uaa_status = "UP";
$prod_asset_status = get_status($PROD_ASSET_URL, $PROD_TOKEN, $PROD_TENANT);
$prod_ts_status = get_status($PROD_TS_URL, $PROD_TOKEN, $PROD_TENANT);
$prod_stuf_status = get_status($PROD_STUF_URL, $PROD_TOKEN, $PROD_TENANT);
$prod_html_line = generate_line($time_stamp, $prod_uaa_status, $prod_ts_status, $prod_asset_status, $prod_stuf_status);
insert_line ($prod_html_line, $prod_report);

printf "PROD UAA STATUS IS $prod_uaa_status\n";
printf "PROD ASSET STATUS IS $prod_asset_status\n";
printf "PROD TS STATUS IS $prod_ts_status\n";
printf "PROD STUF STATUS IS $prod_stuf_status\n";

# FUNCTIONS BELOW:

sub get_token
{
    my ($url, $auth) = @_;
    my $command ="curl -sX POST";
    $command = $command." '$url'";
    $command = $command." -H 'authorization: Basic $auth'";
    $command = $command." -H 'cache-control: no-cache'";
    $command = $command." -H 'content-type: application/x-www-form-urlencoded'";

    my $response = `$command`;
#    printf "RTESPONSE WAS $response\n";
    my $decoded_response = decode_json $response;
    my $token = $decoded_response->{'access_token'};
    return $token;
}

sub get_status
{
    my ($url, $token, $tenant) = @_;
    my $command ="curl -sX GET";
    my $status1;
    $command = $command." '$url'";
    $command = $command." -H 'authorization: Bearer $token'";
    $command = $command." -H 'cache-control: no-cache'";
    $command = $command." -H 'tenant: $tenant'";

    my $response = `$command`;
    my $decoded_response = decode_json $response;
    my $status = $decoded_response->{'status'};
    if (!$status)
    {
        $status = ${ $decoded_response->{'errors'}->[0] }{'httpStatusCode'};
        if (!$status)
        {
            $status = $response;
            printf "STATUS IS $status\n";
        }
    }
    return $status;
}

sub generate_line
{
    my ($time_stamp_passed, $uaa_status, $ts_status, $asset_status, $stuf_status) = @_;
    my $uaa_color;
    my $uaa_hover;
    my $ts_color;
    my $ts_hover;
    my $asset_color;
    my $asset_hover;
    my $stuf_color;
    my $stuf_hover;
    my $ret_val;

    if ($uaa_status ne "UP")
    {
        $uaa_hover = "<div title=\"$uaa_status\">DOWN</div>";
#        $uaa_status = "DOWN";
        $uaa_status = $uaa_hover;
        $uaa_color = "#FF0000";
    }
    else
    {
        $uaa_color = "#00FF00";
    }

    if ($ts_status ne "UP")
    {
        $ts_hover = "<div title=\"$ts_status\">DOWN</div>";
#        $ts_status = "DOWN";
        $ts_status = $ts_hover;
        $ts_color = "#FF0000";
    }
    else
    {
        $ts_color = "#00FF00";
    }

    if ($asset_status ne "UP")
    {
        $asset_hover = "<div title=\"$asset_status\">DOWN</div>";
#        $asset_status = "DOWN";
        $asset_status = $asset_hover;
        $asset_color = "#FF0000";
    }
    else
    {
        $asset_color = "#00FF00";
    }

    if ($stuf_status ne "UP")
    {
        $stuf_hover = "<div title=\"$stuf_status\">DOWN</div>";
#        $stuf_status = "DOWN";
        $stuf_status = $stuf_hover;
        $stuf_color = "#FF0000";
    }
    else
    {
        $stuf_color = "#00FF00";
    }

    $ret_val = "<tr bgcolor=\"#30aaf4\"><td NOWRAP>$time_stamp_passed</td><td bgcolor=\"$uaa_color\">$uaa_status</td><td bgcolor=\"$ts_color\">$ts_status</td><td bgcolor=\"$asset_color\">$asset_status</td><td bgcolor=\"$stuf_color\">$stuf_status</td></tr>";

    return $ret_val;
}

sub insert_line
{
    my ($line, $file) = @_;
    local $/;
    open FILE, $file or die "Couldn't open $file: $!";
    my $file_lines = <FILE>;
    close FILE;

    my $pos1 = index ($file_lines, "-->");
    my $str1 = substr ($file_lines, 0, $pos1 + 4);
    my $str2 = substr ($file_lines, $pos1 + 4);

    my $new_lines = "$str1\n $line\n $str2";

    open(my $fh, '>', $file);
    print $fh $new_lines;
    close $fh
 }
