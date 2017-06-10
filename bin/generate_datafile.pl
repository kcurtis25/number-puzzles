#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use SCP::ProblemGenerator;

my $usage = "Usage: generate_datafile.pl [ -t type ] [ --min min-result ] [ --max max-result ]";

my ($type, $min_result, $max_result);
die $usage unless GetOptions(
    'type=s'       => \$type,
    'min-result=s' => \$min_result,
    'max-result=s' => \$max_result,
);

$type ||= 'Addition';

my $args = {};
$args->{min_result} = $min_result if $min_result;
$args->{max_result} = $max_result if $max_result;

# Set as a global, with default values
my $generator = SCP::ProblemGenerator->new($args);
$generator->print();
