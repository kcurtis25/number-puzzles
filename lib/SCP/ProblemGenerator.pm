package SCP::ProblemGenerator;

use strict;
use warnings;

use Moose;

has max_result   => (is => 'ro', isa => 'Int', default => 10);
has min_result   => (is => 'ro', isa => 'Int', default => 0);
has include_zero => (is => 'ro', isa => 'Int', default => 0);

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

=head2 generate

Add problems to the 'possible_problems' array

=cut

sub generate
{
	my $self = shift;

	my $max_result = $self->max_result;
	my $result = $self->min_result;
	
	while ($result <= $max_result)
	{
        	my $x = 0;
        	while ($x < $max_result)
        	{
                	$x++;
					next if ($result == $x && !$self->include_zero);
					my $problem = $self->get_problem($result, $x);
					next unless $problem;
					$self->add_possible_problem({ result => $result, problem => $problem });
        	}
        	$result = $self->next_result($result);
	}
}

=head2 $self->next_result ($current_result)

Given a result (answer to an equation), return the next possible result

=cut

sub next_result
{
	my $self = shift;
	my ($current_result) = @_;
	
	return ++$current_result;
}

=head2 $self->get_problem ($result, $x)

=cut

sub get_problem
{
	my $self = shift;
	my ($result, $x) = @_;
	
	my $y = $result - $x;
	if ($self->min_result >= 0)
	{
		return undef unless $x > -1 && $y > -1;
	}
	return "$x + $y";
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
