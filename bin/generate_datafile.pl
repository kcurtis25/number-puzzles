#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use SCP::ProblemGenerator;

my $usage = q{Usage: generate_datafile.pl [ -t type ] [ --include-zero ] [ .. type specific  options ]

Options are dependant on the type

Addition    : [ --min min-result ] [ --max max-result ]
Timestables : --times-tables 2,3,4

};

my ($type, $min_result, $max_result, $times_tables, $include_zero);
die $usage unless GetOptions(
    'type=s'       => \$type,
    'min-result=s' => \$min_result,
    'max-result=s' => \$max_result,
    'times-tables=s' => \$times_tables,
    'z|include-zero' => \$include_zero,
);

$type ||= 'Addition';

my $generator_args = { };
$generator_args->{min_result}   = $min_result   if $min_result;
$generator_args->{max_result}   = $max_result   if $max_result;
$generator_args->{times_tables} = $times_tables if $times_tables;

my $args = {
	type => $type,
	generator_args => $generator_args,
};
$args->{include_zero} = $include_zero if $include_zero;

# Set as a global, with default values
my $generator = SCP::ProblemGenerator->new($args);
$generator->print();
