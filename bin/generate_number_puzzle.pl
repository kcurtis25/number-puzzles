#!/usr/bin/perl

=head1 NAME

bin/generate_number_puzzle.pl

=head1 DESCRIPTION

Generate the number puzzle

Usage: generate_number_puzzle.pl --datafile=puzzle-numbers01.dat --format=pdf

=cut

use strict;
use warnings;

use Template;
use Getopt::Long;
use Data::Dumper;
use File::Temp qw/tempfile/;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use SCP::PuzzleGenerator;

my $usage = "usage: generate_number_puzzle.pl --datafile=puzzle-numbers01.dat --format=pdf";

my ($datafile, $format);
die $usage unless GetOptions(
	'datafile=s'  => \$datafile,
	'format=s'    => \$format,
);
$datafile ||= 'puzzle-numbers01.dat';
$format ||= 'pdf';
my $backup_datafile = 'data/addition_to_10-bkp.dat';

my $base_dir = "$Bin/../";
my $puzzle_config = $base_dir . "data/" . $datafile;

unless ($format =~ m/^(pdf|tex)$/) {
	warn "Format must be 'pdf' or 'tex'\n";
	die $usage;
}

my $puzzle = SCP::PuzzleGenerator->new({ config_datafile => $puzzle_config });
my $template_vars = $puzzle->generate();

my $template_config = {
	INCLUDE_PATH    => [ $base_dir ],
};

my $temporary_file = $puzzle->_temp_file_name('tex');
my $tt = Template->new($template_config);
$tt->process('puzzle.tt', $template_vars, $temporary_file) || die $tt->error();;

my $dispatcher = $puzzle->get_dispatcher($format);
$dispatcher->($temporary_file);

exit;
