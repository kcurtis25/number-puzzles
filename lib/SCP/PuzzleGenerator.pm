package SCP::PuzzleGenerator;

use strict;
use warnings;

use Moose;
use Path::Tiny;
use List::Util 'shuffle';

use SCP::PuzzlePageGenerator;

has config_datafile         => (is => 'ro', isa => 'Maybe[Str]');
has backup_problem_datafile => (is => 'ro', isa => 'Str', default => 'addition_to_10-bkp.dat');
has main_problem_datafile   => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_main_problem_datafile');

has puzzle_meta => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_puzzle_meta');

sub _build_puzzle_meta
{
	my $self = shift;

	my $datafile = $self->config_datafile || die "Either config_datafile or puzzle_meta is required";
	my $meta;

	open META_FH, "<:raw", $datafile;
	while (my $line = <META_FH>) {
		chomp $line;
		my ($key, $value) = split(/:\s+/, $line, 2);
		$key = lc($key);
		$meta->{$key} = $value;
	}
	return $meta;
}

has data_dir => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_data_dir');

sub _build_data_dir
{
	my $self = shift;

	# This is hard coded and controled by Docker
	return "/opt/app/data/";
}

has main_problem_datafile => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_main_problem_datafile');

sub _build_main_problem_datafile
{
	my $self = shift;

	my $puzzle_meta      = $self->puzzle_meta;
	my $problem_datafile = $puzzle_meta->{formulas};
	return $self->data_dir . $problem_datafile;
}

has phrase_answer => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_phrase_answer');

sub _build_phrase_answer
{
	my $self = shift;
	return $self->puzzle_meta->{answer};
}

has required_letters => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_required_letters');

sub _build_required_letters
{
	my $self = shift;

	my $string = $self->phrase_answer;
	my $letters;

	# Remove whitespace and upper case
	$string =~ s/\s+//g;
	$string = uc($string);

	# Split, and store as hash
	my @all_letters = split(//, $string);
	$letters->{$_} = 1 foreach @all_letters;
	my @uniq_letters = sort keys %$letters;
	return \@uniq_letters;
}

=head2 $self->_temp_file_name ($suffix)

Provide a temporary filename (eg /tmp/puzzle-numbers_2RjB.tex)

=cut

sub _temp_file_name
{
	my ($self, $suffix) = @_;
	my $template = 'puzzle-numbers_XXXX';
	my $temp_dir = '/tmp/';
	my $file     = File::Temp->new($template, SUFFIX => $suffix, DIR => $temp_dir, UNLINK => 1)->filename;
	return $file;
}

sub generate
{
	my $self = shift;
	my $required_letters = $self->required_letters || die "Cannot generate puzzle: Cannot determine required letters";

	my $meta = $self->puzzle_meta;
	my $possible_problems = $self->get_problems_from_file($self->main_problem_datafile);
	my $backup_possible_problems = $self->get_problems_from_file($self->backup_problem_datafile);

	my $page_args = {
		possible_problems => $possible_problems,
		backup_possible_problems => $backup_possible_problems,
		font_size => $meta->{font_size},
	};

	my @pages;
	my $number_of_pages = $meta->{number_of_pages} || 1;
	$number_of_pages = 50 if $number_of_pages > 50;
	for (my $i = 0; $i < $number_of_pages; $i++) {
		my $page_generator = SCP::PuzzlePageGenerator->new(puzzle_meta => $meta, required_letters => $required_letters);
		my $page_data = $page_generator->generate_page($page_args);
		push (@pages, $page_data);
	}

	my $template_vars = {
		meta  => $meta,
		pages => \@pages,
	};
	return $template_vars;
}

sub get_problems_from_file
{
	my ($self, $datafile) = @_;
	my $possible_problems;
	unless ($datafile =~ m%^/%) {
		$datafile = $self->data_dir . $datafile;
	}

	my $rc = open FILE, "<:raw", $datafile;
	unless ($rc) {
		warn "Failed to open $datafile. $!\n";
	}
	while (my $line = <FILE>) {
		chomp $line;
		my ($key, $value) = split(/\s+/, $line, 2);
		push(@{ $possible_problems->{$key} }, $value);
	}
	close(FILE);
	return $possible_problems;
}

=head2 $self->get_dispatcher ($format)

Return function sub based on the given format. This function will take a
$filename of the generated tex file.

=cut

sub get_dispatcher
{
	my ($self, $format) = @_;
	my $base_dir = $self->data_dir . "../";

	my $dispatcher = {
		tex => sub {
			my ($filename) = @_;
			my $fh;
			open($fh, '<', $filename) || die("Could not open temporary file $filename for tex output");
			while (my $line = <$fh>) {
				print $line;
			}
		},
		pdf => sub {
			my ($filename) = @_;
			system("pdflatex -interaction=nonstopmode -output-directory=/tmp $filename");
		},
	};
	return $dispatcher->{$format};
}

1;
