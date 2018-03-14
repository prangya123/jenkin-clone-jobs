#!/usr/bin/perl
use warnings;
use strict;
use JSON::PP;
use Data::Dumper qw(Dumper);
$Data::Dumper::Terse = 1;

my $time_stamp = `echo \$(date +"%a %F %r")`;
chomp ($time_stamp);

my $widgets_report = "widgets_dashboard_details.html";

my $DEV01_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $DEV01_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo=";
my $DEV01_TENANT="1f7a22b1-72e1-4915-94db-ff623fa2002e";
my $DEV01_WRS="https://apm-widget-repo-service-svc-sbxdev.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $DEV01_TOKEN;
my %dev01_hash;
my %dev01_widget_info;

my $QA01_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $QA01_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo=";
my $QA01_TENANT="f1d57854-05d9-4e94-b9bb-b80ec812a309";
my $QA01_WRS="https://apm-widget-repo-service-svc-sbxqa.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $QA01_TOKEN;
my %qa01_hash;
my %qa01_widget_info;

my $PERF01_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $PERF01_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo=";
my $PERF01_TENANT="2f827688-2370-496f-b210-830a85d9581e";
my $PERF01_WRS="https://apm-widget-repo-service-svc-ogperf.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $PERF01_TOKEN;
my %perf01_hash;
my %perf01_widget_info;

my $DEV02_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $DEV02_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $DEV02_TENANT="90226fdc-0648-42a3-8e66-e019cf3b2cce";
my $DEV02_WRS="https://apm-widget-repo-service-svc-apm-dev02.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $DEV02_TOKEN;
my %dev02_hash;
my %dev02_widget_info;

my $QA02_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $QA02_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $QA02_TENANT="8b1a3e7d-ef80-4c6d-8182-5d406559d104";
my $QA02_WRS="https://apm-widget-repo-service-svc-apm-qa02.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $QA02_TOKEN;
my %qa02_hash;
my %qa02_widget_info;

my $UAT01_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $UAT01_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $UAT01_TENANT="75eaec32-a802-4c7b-9f70-b11efd06ced4";
my $UAT01_WRS="https://apm-widget-repo-service-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/v1/widgets/";
my $UAT01_TOKEN;
my %uat01_hash;
my %uat01_widget_info;

my $DEMODEV02_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $DEMODEV02_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $DEMODEV02_TENANT="783b862e-f0cd-4cf6-8572-36c6d4280da1";
my $DEMODEV02_WRS="https://apm-widget-repo-service-svc-apm-demodev02.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $DEMODEV02_TOKEN;
my %demodev02_hash;
my %demodev02_widget_info;

my $DEMOPROD01_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser02&password=Pa55w0rd";
my $DEMOPROD01_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $DEMOPROD01_TENANT="140235e0-08b3-4c61-b473-241574cb889b";
my $DEMOPROD01_WRS="https://apm-widget-repo-service-svc-apmdemo.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $DEMOPROD01_TOKEN;
my %demoprod01_hash;
my %demoprod01_widget_info;

## DEMOPROD02 ##

my $DEMOPROD02_UAA="https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.26b305ec-f801-4e76-b03a-ef409403546e.359a82f6-500a-4f27-b63a-6adfc1e819f1&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $DEMOPROD02_AUTHORIZATION="aW5nZXN0b3IuMjZiMzA1ZWMtZjgwMS00ZTc2LWIwM2EtZWY0MDk0MDM1NDZlLjM1OWE4MmY2LTUwMGEtNGYyNy1iNjNhLTZhZGZjMWU4MTlmMTo=";
my $DEMOPROD02_TENANT="bd7e3b53-a1e6-4301-8da3-b6fe51d1cc31";
my $DEMOPROD02_WRS="https://apm-widget-repo-service-svc-apm-demoprod02.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $DEMOPROD02_TOKEN;
my %demoprod02_hash;
my %demoprod02_widget_info;



my $PROD01_UAA="https://d1e53858-2903-4c21-86c0-95edc7a5cef2.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token/?client_id=ingestor.57e72dd3-6f9e-4931-b4bc-cd04eaaff3e3.1f7dbe12-2372-439e-8104-06a5f4098ec9&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $PROD01_AUTHORIZATION="aW5nZXN0b3IuNTdlNzJkZDMtNmY5ZS00OTMxLWI0YmMtY2QwNGVhYWZmM2UzLjFmN2RiZTEyLTIzNzItNDM5ZS04MTA0LTA2YTVmNDA5OGVjOTo=";
my $PROD01_TENANT="b7875037-e278-43d3-9f9f-8b624b19ba8d";
my $PROD01_WRS="https://apm-widget-repo-service-svc-prod.app-api.aws-usw02-pr.predix.io/v1/widgets/";
my $PROD01_TOKEN;
my %prod01_hash;
my %prod01_widget_info;

my $index;
my $num = 1;
my $widget_name;
my @widget_names;
my @widget_versions;
my $contents;
my $data1;
my $num1;
my $pretty1;

## DEV01 ## 

$DEV01_TOKEN = get_token($DEV01_UAA, $DEV01_AUTHORIZATION);
generate_json($DEV01_WRS, $DEV01_TOKEN, $DEV01_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $dev01_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $dev01_widget_info{$v1} = $data1->{widgets}[$i1];
}

# foreach my $wid1 (sort keys %dev01_widget_info) {
#     my $tt1 = $dev01_widget_info{$wid1};
#     print "$wid1 IS \n";
#     print Dumper $tt1;
#     printf " ************************************************ \n";
# }

## QA01 ## 

$QA01_TOKEN = get_token($QA01_UAA, $QA01_AUTHORIZATION);
generate_json($QA01_WRS, $QA01_TOKEN, $QA01_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $qa01_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $qa01_widget_info{$v1} = $data1->{widgets}[$i1];
}

## PERF01 ## 

$PERF01_TOKEN = get_token($PERF01_UAA, $PERF01_AUTHORIZATION);
generate_json($PERF01_WRS, $PERF01_TOKEN, $PERF01_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $perf01_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $perf01_widget_info{$v1} = $data1->{widgets}[$i1];
}

## DEV02 ## 

$DEV02_TOKEN = get_token($DEV02_UAA, $DEV02_AUTHORIZATION);
generate_json($DEV02_WRS, $DEV02_TOKEN, $DEV02_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $dev02_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $dev02_widget_info{$v1} = $data1->{widgets}[$i1];
}

## QA02 ## 

$QA02_TOKEN = get_token($QA02_UAA, $QA02_AUTHORIZATION);
generate_json($QA02_WRS, $QA02_TOKEN, $QA02_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $qa02_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $qa02_widget_info{$v1} = $data1->{widgets}[$i1];
}

## UAT01 ## 

$UAT01_TOKEN = get_token($UAT01_UAA, $UAT01_AUTHORIZATION);
generate_json($UAT01_WRS, $UAT01_TOKEN, $UAT01_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $uat01_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $uat01_widget_info{$v1} = $data1->{widgets}[$i1];
}

## DEMODEV02 ## 

$DEMODEV02_TOKEN = get_token($DEMODEV02_UAA, $DEMODEV02_AUTHORIZATION);
generate_json($DEMODEV02_WRS, $DEMODEV02_TOKEN, $DEMODEV02_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $demodev02_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $demodev02_widget_info{$v1} = $data1->{widgets}[$i1];
}

## DEMOPROD01 ## 

$DEMOPROD01_TOKEN = get_token($DEMOPROD01_UAA, $DEMOPROD01_AUTHORIZATION);
generate_json($DEMOPROD01_WRS, $DEMOPROD01_TOKEN, $DEMOPROD01_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $demoprod01_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $demoprod01_widget_info{$v1} = $data1->{widgets}[$i1];
}
## DEMOPROD02 ##

$DEMOPROD02_TOKEN = get_token($DEMOPROD02_UAA, $DEMOPROD02_AUTHORIZATION);
generate_json($DEMOPROD02_WRS, $DEMOPROD02_TOKEN, $DEMOPROD02_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $demoprod02_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'};
    $demoprod02_widget_info{$v1} = $data1->{widgets}[$i1];
}

#print Dumper(\%demoprod02_hash);

## PROD01 ## 

$PROD01_TOKEN = get_token($PROD01_UAA, $PROD01_AUTHORIZATION);
generate_json($PROD01_WRS, $PROD01_TOKEN, $PROD01_TENANT);

@widget_names = `cat widgets_response.json | jq -r '"\\(.id)"'`;
@widget_versions = `cat widgets_response.json | jq -r '"\\(.properties.ARTIFACT_VERSION)"'`;
chomp (@widget_names);
chomp (@widget_versions);

for($index=0;$index<=$#widget_names;$index++)
{
    my $name1;
    my $version1;
    $name1 = $widget_names[$index];
    $version1 = $widget_versions[$index];
    $prod01_hash{$name1} = $version1;
}

$contents = read_file();
$data1 = decode_json($contents);
$num1 = keys $data1->{widgets};

for (my $i1=0; $i1<$num1; $i1++)
{
    my $v1 = $data1->{widgets}[$i1]->{'id'}; 
    $prod01_widget_info{$v1} = $data1->{widgets}[$i1];
}

# Create HTML Report below

open (my $fh, '>', $widgets_report) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Widgets dashboard</title>\n<body>\n";
print $fh "<link rel=\"stylesheet\" href=\"styles_widgets.css\">";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"5\">IntelliStream widgets dashboard</font> - Last run on $time_stamp PST</th></tr>\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th NOWRAP>Sr. No.</th><th>Widget Name</th><th>DEV01</th><th>DEV02</th><th>QA01</th><th>QA02</th><th>PERF01</th><th>UAT01</th><th>DEMODEV02</th><th>DEMOPROD01</th><th>DEMOPROD02</th><th>PROD01</th></tr>\n";

my @dev_widgets = sort keys %dev01_hash;
for $widget_name (@dev_widgets)
{
    my $widget_version_dev = $dev01_hash{$widget_name};
    my $widget_version_qa = $qa01_hash{$widget_name};
    my $widget_version_perf = $perf01_hash{$widget_name};
    my $widget_version_dev02 = $dev02_hash{$widget_name};
    my $widget_version_qa02 = $qa02_hash{$widget_name};
    my $widget_version_uat01 = $uat01_hash{$widget_name};
    my $widget_version_demodev02 = $demodev02_hash{$widget_name};
    my $widget_version_demoprod01 = $demoprod01_hash{$widget_name};
	my $widget_version_demoprod02 = $demoprod02_hash{$widget_name};
    my $widget_version_prod01 = $prod01_hash{$widget_name};

    if (!defined $widget_version_dev)
    {
        $widget_version_dev = "N/A";
    }
    elsif ($widget_version_dev eq "null")
    {
        $widget_version_dev = "N/A";
    }
    else
    {
        $widget_version_dev = $widget_name . "_" . $widget_version_dev . ".tar.gz";
    }

    if (!defined $widget_version_qa)
    {
        $widget_version_qa = "N/A";
    }
    elsif ($widget_version_qa eq "null")
    {
        $widget_version_qa = "N/A";
    }
    else
    {
        $widget_version_qa = $widget_name . "_" . $widget_version_qa . ".tar.gz";
    }

    if (!defined $widget_version_perf)
    {
        $widget_version_perf = "N/A";
    }
    elsif ($widget_version_perf eq "null")
    {
        $widget_version_perf = "N/A";
    }
    else
    {
        $widget_version_perf = $widget_name . "_" . $widget_version_perf . ".tar.gz";
    }

    if (!defined $widget_version_dev02)
    {
        $widget_version_dev02 = "N/A";
    }
    elsif ($widget_version_dev02 eq "null")
    {
        $widget_version_dev02 = "N/A";
    }
    else
    {
        $widget_version_dev02 = $widget_name . "_" . $widget_version_dev02 . ".tar.gz";
    }
    
    if (!defined $widget_version_qa02)
    {
        $widget_version_qa02 = "N/A";
    }
    elsif ($widget_version_qa02 eq "null")
    {
        $widget_version_qa02 = "N/A";
    }
    else
    {
        $widget_version_qa02 = $widget_name . "_" . $widget_version_qa02 . ".tar.gz";
    }

    if (!defined $widget_version_uat01)
    {
        $widget_version_uat01 = "N/A";
    }
    elsif ($widget_version_uat01 eq "null")
    {
        $widget_version_uat01 = "N/A";
    }
    else
    {
        $widget_version_uat01 = $widget_name . "_" . $widget_version_uat01 . ".tar.gz";
    }

    if (!defined $widget_version_demodev02)
    {
        $widget_version_demodev02 = "N/A";
    }
    elsif ($widget_version_demodev02 eq "null")
    {
        $widget_version_demodev02 = "N/A";
    }
    else
    {
        $widget_version_demodev02 = $widget_name . "_" . $widget_version_demodev02 . ".tar.gz";
    }

    if (!defined $widget_version_demoprod01)
    {
        $widget_version_demoprod01 = "N/A";
    }
    elsif ($widget_version_demoprod01 eq "null")
    {
        $widget_version_demoprod01 = "N/A";
    }
    else
    {
        $widget_version_demoprod01 = $widget_name . "_" . $widget_version_demoprod01 . ".tar.gz";
    }
	
    if (!defined $widget_version_demoprod02)
    {
        $widget_version_demoprod02 = "N/A";
    }
    elsif ($widget_version_demoprod02 eq "null")
    {
        $widget_version_demoprod02 = "N/A";
    }
    else
    {
        $widget_version_demoprod02 = $widget_name . "_" . $widget_version_demoprod02 . ".tar.gz";
    }

    if (!defined $widget_version_prod01)
    {
        $widget_version_prod01 = "N/A";
    }
    elsif ($widget_version_prod01 eq "null")
    {
        $widget_version_prod01 = "N/A";
    }
    else
    {
        $widget_version_prod01 = $widget_name . "_" . $widget_version_prod01 . ".tar.gz";
    }

# Print table row below
    print $fh "<tr BGCOLOR=\"#e2f4ff\"><td BGCOLOR=\"#30aaf4\">$num</td><td BGCOLOR=\"#30aaf4\">$widget_name</td>";
    print $fh "<td><a class=\"button\" href=\"#dev01_$widget_name\">$widget_version_dev</a></td>";
    print $fh "<td><a class=\"button\" href=\"#dev02_$widget_name\">$widget_version_dev02</a></td>";
    print $fh "<td><a class=\"button\" href=\"#qa01_$widget_name\">$widget_version_qa</a></td>";
    print $fh "<td><a class=\"button\" href=\"#qa02_$widget_name\">$widget_version_qa02</a></td>";
    print $fh "<td><a class=\"button\" href=\"#perf01_$widget_name\">$widget_version_perf</a></td>";
    print $fh "<td><a class=\"button\" href=\"#uat01_$widget_name\">$widget_version_uat01</a></td>";
    print $fh "<td><a class=\"button\" href=\"#demodev02_$widget_name\">$widget_version_demodev02</a></td>";
    print $fh "<td><a class=\"button\" href=\"#demoprod01_$widget_name\">$widget_version_demoprod01</a></td>";
	print $fh "<td><a class=\"button\" href=\"#demoprod02_$widget_name\">$widget_version_demoprod02</a></td>";
    print $fh "<td><a class=\"button\" href=\"#prod01_$widget_name\">$widget_version_prod01</a></td></tr>\n";

# Print div ids below
    print $fh "<div id=\"dev01_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>DEV01 $widget_name</h2><div><PRE>";
    $pretty1 = JSON::PP->new->pretty->encode($dev01_widget_info{$widget_name});
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"dev02_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>DEV02 $widget_name</h2><div><PRE>";
    if ($dev02_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($dev02_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"qa01_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>QA01 $widget_name</h2><div><PRE>";
    if ($qa01_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($qa01_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"qa02_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>QA02 $widget_name</h2><div><PRE>";
    if ($qa02_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($qa02_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"perf01_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>PERF01 $widget_name</h2><div><PRE>";
    if ($perf01_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($perf01_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"uat01_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>UAT01 $widget_name</h2><div><PRE>";
    if ($uat01_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($uat01_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"demodev02_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>DEMODEV02 $widget_name</h2><div><PRE>";
    if ($demodev02_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($demodev02_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"demoprod01_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>DEMOPROD01 $widget_name</h2><div><PRE>";
    if ($demoprod01_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($demoprod01_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";
	
	## DEMOPROD02 ##
        print $fh "<div id=\"demoprod02_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>DEMOPROD02 $widget_name</h2><div><PRE>";
    if ($demoprod02_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($demoprod02_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    print $fh "<div id=\"prod01_$widget_name\" class=\"modal-window\"><div class=\"header\"><a href=\"#modal-close\" title=\"Close\" class=\"modal-close\">Close</a><h2>PROD01 $widget_name</h2><div><PRE>";
    if ($prod01_widget_info{$widget_name})
    {
        $pretty1 = JSON::PP->new->pretty->encode($prod01_widget_info{$widget_name});
    }
    else
    {
        $pretty1 = "NULL";
    }
    print $fh $pretty1;
    print $fh "</PRE></br></div></div></div>\n";

    $num++;
}

# for($index=0;$index<=$#widget_names;$index++)
# {
#     my $num = $index + 1;
#     print $fh "<tr><td>$num</td><td>$widget_names[$index]</td><td>$widget_versions[$index]</td></tr>\n";
# }

print $fh "</table>\n</body>\n</html>\n";
close($fh);


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
    my $decoded_response = decode_json $response;
    my $token = $decoded_response->{'access_token'};
    return $token;
}

sub generate_json
{
    my ($wrs, $token, $tenant) = @_;
    my $command ="curl -sX GET";
    $command = $command." '$wrs'";
    $command = $command." -H 'authorization: Bearer $token'";
    $command = $command." -H 'cache-control: no-cache'";
    $command = $command." -H 'tenant: $tenant'";
#    $command = $command." | jq -r '.widgets[]'";

    `$command > widgets_response1.json`;

    `cat widgets_response1.json | jq -r '.widgets[]' > widgets_response.json`;
}

sub read_file
{
    my $test_obj;
    {
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "widgets_response1.json";
    $test_obj = <$fh>;
    close $fh;
    }
    return $test_obj;
}
