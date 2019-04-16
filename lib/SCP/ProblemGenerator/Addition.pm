package SCP::ProblemGenerator::Addition;

use strict;
use warnings;

use Moose;

has max_result   => (is => 'ro', isa => 'Int', default => 10);
has min_result   => (is => 'ro', isa => 'Int', default => 0);

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

1;
