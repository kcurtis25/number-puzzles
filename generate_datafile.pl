#!/usr/bin/perl

use strict;

my $max_total = 99;

my $total = 0;
while ($total < $max_total + 1)
{
	my $x = 0;
	while ($x < $max_total)
	{
		$x++;
		my $y = $total - $x;
		next unless $x > -1 && $y > -1;
		print "$total	$x + $y\n";
	}
	$total++;
}

