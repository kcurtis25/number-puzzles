#!/usr/bin/perl

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
$puzzle->generate();

my $template_config = {
	INCLUDE_PATH    => [ $base_dir ],
};

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
#warn Dumper($template_vars);

my $temporary_file = _temp_file_name('tex');
my $tt = Template->new($template_config);
$tt->process('puzzle.tt', $template_vars, $temporary_file) || die $tt->error();;

my $dispatcher = get_dispatcher();
$dispatcher->{$format}->($temporary_file);

=head1 METHODS

=cut

sub _temp_file_name 
{
	my ($suffix) = @_;
	my $template = 'puzzle-numbers_XXXX';
	my $temp_dir = '/tmp/';
	my $file = File::Temp->new($template, SUFFIX => $suffix, DIR => $temp_dir, UNLINK => 1)->filename;
	return $file;
}

sub get_dispatcher
{
	my $dispatcher = {
		tex => sub {
			my ($filename) = @_;
			my $fh;
			open ($fh, '<', $filename) || die ("Could not open temporary file $filename for tex output");
			while (my $line = <$fh>) {
				print $line;
			}
		},
		pdf => sub {
			my ($filename) = @_;
			my $output_dir = "${base_dir}/output";
			system("pdflatex -interaction=nonstopmode -output-directory=$output_dir $filename");
		},
	};
	return $dispatcher;
}

exit;
