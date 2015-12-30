#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use SCP::ProblemGenerator;

# Set as a global, with default values
my $generator = SCP::ProblemGenerator->new();
$generator->print();
