package SCP::ProblemGenerator::TimesTables;

use strict;
use warnings;

use Moose;

has times_tables   => (is => 'ro', isa => 'Str');
has max_2nd_factor => (is => 'ro', isa => 'Int', default => 12);

has times_tables_hash   => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_times_tables_hash');
has max_result => (is => 'ro', isa => 'Int', lazy => 1, builder => '_build_max_result');
has min_result   => (is => 'ro', isa => 'Int', default => 0);

sub _build_times_tables_hash
{
	my $self = shift;

	my @times_tables = split /,/, $self->times_tables;
	my $times_tables_hash;

	foreach my $times_table (@times_tables) {
		$times_tables_hash->{$times_table} = 1;
	}
	
	return $times_tables_hash;
}

sub _build_max_result
{
	my $self = shift;

	# In the times tables array, get the maximum value
	my $max_times_table = 0;
	foreach my $times_table (keys %{ $self->times_tables_hash }) {
		$max_times_table = $times_table if $times_table > $max_times_table;
	}

	# The max result will be $max_2nd_factor (12) times that value
	return $max_times_table * $self->max_2nd_factor;
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

	# If $x isn't one of the times tables we are interested in, don't return a problem
	return unless $self->times_tables_hash->{$x};
	
	my $y = $result / $x;
	return if $y > $self->max_2nd_factor;

	# If $y isn't a whole number, return
	return unless $y =~ /^\d+$/;

	return "$x * $y";
}

1;
