#!/usr/bin/perl

use strict;
use warnings;

use Template;
use Getopt::Long;
use Data::Dumper;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use SCP::PuzzleGenerator;

my $usage = "usage: generate_number_puzzle.pl --datafile=puzzle-numbers01.dat";

my ($datafile);
die $usage unless GetOptions(
	'datafile=s'  => \$datafile,
);
$datafile ||= 'puzzle-numbers01.dat';
my $backup_datafile = 'data/addition_to_10-bkp.dat';

my $template_config = {
	INCLUDE_PATH    => ["../."],
};

my $data_dir = "$Bin/../data/";
my $puzzle_config = $data_dir . $datafile;
my $puzzle = SCP::PuzzleGenerator->new({ config_datafile => $puzzle_config });
$puzzle->generate();

my $meta = $puzzle->puzzle_meta;
my $formulas = $puzzle->problems;
my $letter_key = $puzzle->letter_key;
my $required_letters = $puzzle->required_letters;
my $answer_format = $puzzle->answer_format;

my $template_vars = {
	meta       => $meta,
	formulas   => $formulas,
	letters    => $required_letters,
	answer_format    => $answer_format,
};
print Dumper($template_vars);

my $tt = Template->new($template_config);
$tt->process('puzzle.tt', $template_vars) || die $tt->error();;
exit;
