package SCP::ProblemGenerator;

use strict;
use warnings;

use Moose;

has include_zero => (is => 'ro', isa => 'Int', default => 0);

has generator_args => (is => 'ro', isa => 'HashRef');

has type => (required => 1, is => 'ro', isa => 'Str');
has type_based_generator => (is => 'ro', lazy => 1, builder => '_build_type_based_generator');

has 'possible_problems' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	default => sub { [] },
	handles => {
		add_possible_problem     => 'push',
		count_possible_problems  => 'count',
	},
);

=head2 $self->_build_type_based_generator

=cut

sub _build_type_based_generator
{
	my $self = shift;

	my $type = $self->type;
	my $generator_args = $self->generator_args;

	my $type_based_generator;
	if ($type eq 'Addition') {
		require SCP::ProblemGenerator::Addition;
		$type_based_generator = SCP::ProblemGenerator::Addition->new($generator_args);
	} elsif ($type eq 'TimesTables') {
		require SCP::ProblemGenerator::TimesTables;
		$type_based_generator = SCP::ProblemGenerator::TimesTables->new($generator_args);
	} else {
		die "Type $type is not supported)\n";
	}

	return $type_based_generator;
}

=head2 generate

Add problems to the 'possible_problems' array

=cut

sub generate
{
	my $self = shift;

	my $type_based_generator = $self->type_based_generator;

	my $max_result = $type_based_generator->max_result;
	my $result = $type_based_generator->min_result;
	
	while ($result <= $max_result)
	{
        	my $x = 0;
        	while ($x < $max_result)
        	{
                	$x++;
					next if ($result == $x && !$self->include_zero);
					my $problem = $type_based_generator->get_problem($result, $x);
					next unless $problem;
					$self->add_possible_problem({ result => $result, problem => $problem });
        	}
        	$result = $type_based_generator->next_result($result);
	}
}

sub print
{
	my ($self) = @_;
	
	# If we have no problems, then generate
	$self->generate if ($self->count_possible_problems == 0);
	
	my $possible_problems = $self->possible_problems;
	foreach my $problem (@$possible_problems)
	{
		print "$problem->{result}   $problem->{problem}\n";
	}
}

1;
