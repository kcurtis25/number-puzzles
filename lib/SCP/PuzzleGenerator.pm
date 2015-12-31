package SCP::PuzzleGenerator;

use strict;
use warnings;

use Moose;
use Path::Tiny;
use List::Util 'shuffle';

has config_datafile           => (is => 'ro', isa => 'Str', required => 1);
has backup_problem_datafile   => (is => 'ro', isa => 'Str', default => 'addition_to_10-bkp.dat');
has main_problem_datafile     => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_main_problem_datafile');

has puzzle_meta => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_puzzle_meta');

sub _build_puzzle_meta
{
	my $self = shift;
	
	my $datafile = $self->config_datafile;
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
	my $datafile = $self->config_datafile;
	
	my $file = path($self->config_datafile);
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
use Data::Dumper;
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

sub generate
{
	my $self = shift;
	my $required_letters = $self->required_letters;
	
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

	$self->push_formatted_problem({
		answer => $args->{answer},
		question => $args->{question},
		formatted_question => $formatted_question,
		letter => $args->{letter},
	});
}

1;
