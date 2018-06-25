#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $env = $ARGV[0];
my $task = $ARGV[1];
my $product = $ARGV[2];
my $new_artifact = $ARGV[3];

my $contents;
my $row_start;
my $row_offset;
my $cell_end;
my $old_val;
my $env_number;

# $env = "perf01";
# $task = "template";
# $product = "pcm";
# $new_artifact = "ogd-template_pcm_2.0.0.22.zip";

$env = uc ($env);
$task = lc ($task);
$product = lc ($product);

if ($env eq "DEV02")
{
    $env_number = 1;
}
elsif ($env eq "QA02")
{
    $env_number = 2;
}
elsif ($env eq "UAT01")
{
    $env_number = 3;
}
elsif ($env eq "PERF01")
{
    $env_number = 4;
}
elsif ($env eq "PERF02")
{
    $env_number = 5;
}
elsif ($env eq "DEMOPROD01")
{
    $env_number = 6;
}
elsif ($env eq "DEMOPROD02")
{
    $env_number = 7;
}
elsif ($env eq "DEMODEV02")
{
    $env_number = 8;
}
elsif ($env eq "BFX01")
{
    $env_number = 9;
}
elsif ($env eq "PROD")
{
    $env_number = 10;
}
else
{
    printf "Error: Invalid environment passed.\n";
    exit 0;
}

$contents = read_file();

if ($task eq "classification" || $task eq "marker" || $task eq "template")
{
    $task = $task . "_" . $product;
}
$task = ">" . $task . "<";

$row_start = index ($contents, $task);
$row_offset = $row_start;

for (my $i=0; $i < $env_number; $i++) 
{
    my $loc = index ($contents, "Artifact:", $row_offset+1);
    $row_offset = $loc;
#    printf "ROW OFF IS $row_offset\n";
}

$row_offset = $row_offset + 13;
$cell_end = index ($contents, "</td>", $row_offset);
$old_val = substr ($contents, $row_offset, $cell_end-$row_offset, $new_artifact);

#printf "NEW TASK IS $task\n";
#printf "OLD ART IS $old_val\n";

open (my $fh, '>', "post_tenant_config.html") or die "Could not create file.\n";
print $fh $contents;
close($fh);

# FUNCTIONS BELOW

sub read_file
{
    my $test_obj;
    {
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "post_tenant_config.html";
    $test_obj = <$fh>;
    close $fh;
    }
    return $test_obj;
}