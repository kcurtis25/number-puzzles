#!/usr/bin/perl

use strict;
use warnings;

use Try::Tiny;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use SCP::PuzzleDatafiles;

my $usage = "Usage: show_datafile_config.pl";

my $puzzle_datafiles = SCP::PuzzleDatafiles->new();
my $config = $puzzle_datafiles->get_datafile_config();

use Data::Dumper;
#warn Dumper($config);

my $datafiles = $puzzle_datafiles->get_datafile_list();
warn Dumper($datafiles);

