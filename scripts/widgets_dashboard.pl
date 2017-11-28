#!/usr/bin/perl
use warnings;
use strict;
use JSON::PP;
use Data::Dumper qw(Dumper);

my $time_stamp = `echo \$(date +"%a %F %r")`;
chomp ($time_stamp);

my $widgets_report = "widgets_dashboard.html";

my $DEV01_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $DEV01_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo=";
my $DEV01_TENANT="1f7a22b1-72e1-4915-94db-ff623fa2002e";
my $DEV01_WRS="https://apm-widget-repo-service-svc-sbxdev.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $DEV01_TOKEN;
my %dev01_hash;

my $QA01_UAA="https://d1730ade-7c0d-4652-8d44-cb563fcc1e27.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token?client_id=ingestor.496bb641-78b5-4a18-b1b7-fde29788db38.991e5c23-3e9c-4944-b08b-9e83ef0ab598&grant_type=password&username=FuncUser01&password=Pa55w0rd";
my $QA01_AUTHORIZATION="aW5nZXN0b3IuNDk2YmI2NDEtNzhiNS00YTE4LWIxYjctZmRlMjk3ODhkYjM4Ljk5MWU1YzIzLTNlOWMtNDk0NC1iMDhiLTllODNlZjBhYjU5ODo=";
my $QA01_TENANT="f1d57854-05d9-4e94-b9bb-b80ec812a309";
my $QA01_WRS="https://apm-widget-repo-service-svc-sbxqa.apm.aws-usw02-pr.predix.io/v1/widgets/";
my $QA01_TOKEN;
my %qa01_hash;

my $index;
my $num = 1;
my $widget_name;
my @widget_names;
my @widget_versions;

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

# Create HTML Report below

open (my $fh, '>', $widgets_report) or die "Could not create file.\n";

print $fh "<html lang=\"en\" xml:lang=\"en\" xmlns= \"http://www.w3.org/1999/xhtml\"><title>Environment dashboard</title>\n<body>\n";
print $fh "<table border=\"1\">\n";
print $fh "<tr bgcolor=\"#30aaf4\"><th colspan=\"100%\" align=\"left\"><font size=\"5\">IntelliStream widgets dashboard</font> - Last run on $time_stamp PST</th></tr>\n";
print $fh "<tr bgcolor=\"#30aaf4\">\n<th NOWRAP>Sr. No.</th><th>Widget Name</th><th>DEV01</th><th>QA01</th></tr>\n";

my @dev_widgets = sort keys %dev01_hash;
for $widget_name (@dev_widgets)
{
    my $widget_version_dev = $dev01_hash{$widget_name};
    my $widget_version_qa = $qa01_hash{$widget_name};

    if (!defined $widget_version_qa)
    {
        $widget_version_qa = "NULL";
    }

    print $fh "<tr><td>$num</td><td>$widget_name</td><td>$widget_version_dev</td><td>$widget_version_qa</td></tr>\n";

    $num++;

#    printf "NAME: $widget_name and version is: $widget_version_dev AND $widget_version_qa \n";
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
    $command = $command." | jq -r '.widgets[]'";

    `$command > widgets_response.json`;
}