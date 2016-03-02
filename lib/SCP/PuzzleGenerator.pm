package SCP::PuzzleGenerator;

use strict;
use warnings;

use Moose;
use Path::Tiny;
use List::Util 'shuffle';

has config_datafile           => (is => 'ro', isa => 'Maybe[Str]');
has backup_problem_datafile   => (is => 'ro', isa => 'Str', default => 'addition_to_10-bkp.dat');
has main_problem_datafile     => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_main_problem_datafile');

has puzzle_meta => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_puzzle_meta');

sub _build_puzzle_meta
{
	my $self = shift;
	
	my $datafile = $self->config_datafile || die "Either config_datafile or puzzle_meta is required";
	my $meta;

	open META_FH, "<:raw", $datafile;
	while (my $line = <META_FH>)
	{
		chomp $line;
		my ($key, $value) = split(/:\s+/, $line, 2);
		$key = lc($key);
		$meta->{$key} = $value;
	};
	return $meta;
}

has data_dir     => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_data_dir');

sub _build_data_dir
{
	my $self = shift;
	my $datafile = $self->config_datafile || "../data/temp.dat";
	
	my $file = path($datafile);
	my $dirname = $file->dirname('.dat');
	
	return $dirname;
}

has main_problem_datafile     => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_main_problem_datafile');

sub _build_main_problem_datafile
{
	my $self = shift;
	my $puzzle_meta = $self->puzzle_meta;
	my $problem_datafile = $puzzle_meta->{formulas};
	return $self->data_dir . $problem_datafile;
}

has phrase_clue => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_phrase_clue');

sub _build_phrase_clue
{
	my $self = shift;
	return $self->puzzle_meta->{question};
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

has 'problems' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	default => sub { [] },
	handles => {
		push_formatted_problem    => 'push',
		count_problem             => 'count',
	},
);

has 'letter_key' => ( 
    traits    => ['Hash'],
	is => 'ro', 
	isa => 'HashRef[Str]', 
    handles   => {
        set_letter    => 'set',
    },
);

has answer_format => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_answer_format');

sub _build_answer_format
{
	my $self = shift;
	my $phrase_answer = $self->phrase_answer;
	my $letter_key = $self->letter_key;
	my $answer_format;
	
	# Split to determine size
	my @all_letters = split(//, $phrase_answer);
	
	my $line = 0;
	my $line_size = 0;
	foreach my $letter (@all_letters)
	{   
		$letter = uc($letter);
		my $answer = $letter_key->{$letter};
		$line_size++;
		if ($letter eq ' ')
		{   
			$line_size++;
			if ($line_size > 16)
			{   
				$line++;
				$line_size = 0;
				next;
			}
			$answer = ' ';
		}
		push (@{$answer_format->[$line]}, $answer);
	}
	return $answer_format;
}

=head2 $self->_temp_file_name ($suffix)

Provide a temporary filename (eg /tmp/puzzle-numbers_2RjB.tex)

=cut

sub _temp_file_name
{
	my ($self, $suffix) = @_;
	my $template = 'puzzle-numbers_XXXX';
	my $temp_dir = '/tmp/';
	my $file = File::Temp->new($template, SUFFIX => $suffix, DIR => $temp_dir, UNLINK => 1)->filename;
	return $file;
}


sub generate
{
	my $self = shift;
	my $required_letters = $self->required_letters || die "Cannot generate puzzle: Cannot determine required letters";
	
	my $possible_problems = $self->get_problems_from_file($self->main_problem_datafile);
	my @answers = shuffle(keys %$possible_problems);
	
	my $count = scalar(@$required_letters);
	my $letter_key;
	my $i = 0;
	while ($i < $count)
	{   
		my $answer = $answers[$i];
		last unless $answer;
		my $question = shuffle(@{$possible_problems->{$answer}});
		
		$self->push_problem({
			answer => $answer,
			question => $question,
			letter => $required_letters->[$i],
		});
		
		$self->set_letter($required_letters->[$i] => $answer);
		$i++;
	}
	if ($i < $count)
	{   
		# We don't have enough questions
		my $backup_datafile = $self->backup_problem_datafile;
		die "We don't have enough questions" unless $backup_datafile;
		
		my $possible_problems = $self->get_problems_from_file($self->backup_problem_datafile);
		foreach my $answer (keys %$possible_problems)
		{
			my $question = $possible_problems->{$answer}->[0];
			
			$self->push_problem({
				answer => $answer,
				question => $question,
				letter => $required_letters->[$i],
			});
			
			$self->set_letter($required_letters->[$i] => $answer);
			$i++;
			last unless $required_letters->[$i];
		}
	}
	
	my $template_vars = {
		meta          => $self->puzzle_meta,
		formulas      => $self->problems,
		letters       => $self->required_letters,
		answer_format => $self->answer_format,
	};
	return $template_vars;
}

sub get_problems_from_file
{
	my ($self, $datafile) = @_;
	my $possible_problems;
	unless ($datafile =~ m%^/%)
	{
		$datafile = $self->data_dir . $datafile;
	}
	
	my $rc = open FILE, "<:raw", $datafile;
	unless ($rc)
	{
		warn "Failed to open $datafile. $!\n";
	}
	while (my $line = <FILE>)
	{   
		chomp $line;
		my ($key, $value) = split(/\s+/, $line, 2);
		push (@{ $possible_problems->{$key}}, $value);
	}
	close(FILE);
	return $possible_problems;
}

sub push_problem
{
	my ($self, $args) = @_;
	
	# Put a & at the begining and end, and swap the spaces for '&'
	(my $formatted_question = '&' . $args->{question} . '&') =~ s/ /\&/g;
	
	if ($formatted_question =~ m/_/) {
		# A '_' in the question should be substituted for an underscore to
		# write the answer on. Then append a &
		$formatted_question =~ s/_/\\underline{\\hspace{1.5cm}}/;
		$formatted_question .= '&';
	} else {
		# Else, append a ' = ____' to supply space for the answer
		$formatted_question .= '=&\underline{\hspace{1.5cm}}';
	}
	
	$self->push_formatted_problem({
		answer => $args->{answer},
		question => $args->{question},
		formatted_question => $formatted_question,
		letter => $args->{letter},
	});
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
			open ($fh, '<', $filename) || die ("Could not open temporary file $filename for tex output");
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
