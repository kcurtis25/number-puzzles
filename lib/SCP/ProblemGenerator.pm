package SCP::ProblemGenerator;

use strict;
use warnings;

use Moose;

has max_result   => (is => 'ro', isa => 'Int', default => 10);
has min_result   => (is => 'ro', isa => 'Int', default => 0);

has 'possible_problems' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[HashRef]',
	default => sub { [] },
	handles => {
		all_possible_problems    => 'elements',
		add_possible_problem     => 'push',
		map_possible_problems    => 'map',
		filter_possible_problems => 'grep',
		find_possible_problem    => 'first',
		get_possible_problem     => 'get',
		join_possible_problems   => 'join',
		count_possible_problems  => 'count',
		has_possible_problems    => 'count',
		has_no_possible_problems => 'is_empty',
		sorted_possible_problems => 'sort',
	},
);

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
                	my $y = $result - $x;
                	next unless $x > -1 && $y > -1;
			$self->add_possible_problem({ result => $result, problem => "$x + $y" });
        	}
        	$result = $self->next_result($result);
	}
}

sub next_result
{
	my ($self, $current_value) = @_;
	
	return ++$current_value;
}

sub print
{
	my $self = shift;
	
	# If we have no problems, then generate
	$self->generate if ($self->count_possible_problems == 0);
	
	my $possible_problems = $self->possible_problems;
	foreach my $problem (@$possible_problems)
	{
		print "$problem->{result}   $problem->{problem}\n";
	}
}


1;
