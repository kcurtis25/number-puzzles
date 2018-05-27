package SCP::PuzzlePageGenerator;

use strict;
use warnings;

use Moose;
use Path::Tiny;
use List::Util 'shuffle';

=head1 ATTRIBUTES

=head2 puzzle_meta

This is passed in by SCP::PuzzleGenerator

=cut

has puzzle_meta => (is => 'ro', isa => 'HashRef', required => 1);

has phrase_answer => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_phrase_answer');

sub _build_phrase_answer
{
	my $self = shift;
	return $self->puzzle_meta->{answer};
}

has required_letters => (is => 'ro', isa => 'ArrayRef', required => 1);

has 'problems' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	default => sub { [] },
	handles => {
		push_formatted_problem => 'push',
		count_problem          => 'count',
	},
);

has 'letter_key' => (
	traits  => ['Hash'],
	is      => 'ro',
	isa     => 'HashRef[Str]',
	handles => {
		set_letter => 'set',
	},
);

has answer_format => (is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_answer_format');

sub _build_answer_format
{
	my $self          = shift;
	my $phrase_answer = $self->phrase_answer;
	my $letter_key    = $self->letter_key;
	my $answer_format;

	# Split to determine size
	my @all_letters = split(//, $phrase_answer);

	my $line      = 0;
	my $line_size = 0;
	foreach my $letter (@all_letters) {
		$letter = uc($letter);
		my $answer = $letter_key->{$letter};
		$line_size++;
		if ($letter eq ' ') {
			$line_size++;
			if ($line_size > 16) {
				$line++;
				$line_size = 0;
				next;
			}
			$answer = ' ';
		}
		push(@{ $answer_format->[$line] }, $answer);
	}
	return $answer_format;
}

sub generate_page
{
	my $self = shift;
	my ($args) = @_;

	my $possible_problems = $args->{possible_problems};
	my $backup_possible_problems = $args->{backup_possible_problems};

	my $required_letters = $self->required_letters || die "Cannot generate puzzle: Cannot determine required letters";

	my @answers           = shuffle(keys %$possible_problems);

	my $count = scalar(@$required_letters);
	my $letter_key;
	my $i = 0;
	while ($i < $count) {
		my $answer = $answers[$i];
		last unless $answer;
		my $question = shuffle(@{ $possible_problems->{$answer} });

		$self->push_problem({
				answer   => $answer,
				question => $question,
				letter   => $required_letters->[$i],
			}
		);

		$self->set_letter($required_letters->[$i] => $answer);
		$i++;
	}
	if ($i < $count) {

		# We don't have enough questions
		die "We don't have enough questions" unless $backup_possible_problems;

		foreach my $answer (keys %$backup_possible_problems) {
			my $question = $backup_possible_problems->{$answer}->[0];

			$self->push_problem({
					answer   => $answer,
					question => $question,
					letter   => $required_letters->[$i],
				}
			);

			$self->set_letter($required_letters->[$i] => $answer);
			$i++;
			last unless $required_letters->[$i];
		}
	}

	my $page_data = {
		formulas      => $self->problems,
		letters       => $self->required_letters,
		answer_format => $self->answer_format,
	};
	return $page_data;
}

sub push_problem
{
	my ($self, $args) = @_;
	my $question = $args->{question};
	my $part_count = scalar split(/ /, $question);

	# Put a & at the begining and end, and swap the spaces for '&'
	(my $formatted_question = '&' . $question) =~ s/ /\&/g;

	if ($formatted_question =~ m/_/) {

		# A '_' in the question should be substituted for an underscore to
		# write the answer on. Then append a &
		$formatted_question =~ s/_/\\underline{\\hspace{1cm}}/;

		# Add additional '&' to make 5 columns
		while ($part_count < 5) {
			$formatted_question .= '&';
			$part_count++;
		}
	} else {

		# Else, append a ' = ____' to supply space for the answer
		$formatted_question .= '&=&\underline{\hspace{1.5cm}}';
	}

	$self->push_formatted_problem({
			answer             => $args->{answer},
			question           => $args->{question},
			formatted_question => $formatted_question,
			letter             => $args->{letter},
		}
	);
}

1;
