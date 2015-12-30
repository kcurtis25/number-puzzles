use strictures 1;

=head1 NAME

ProblemGenerator Testing

=head1 DESCRIPTION

Unit testing for ProblemGenerator role.

=head1 AUTHOR

Katherine Curtis

=head1 COPYRIGHT

Katherine Curtis

=cut

use Test::Most;
use Try::Tiny;

use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

use SCP::ProblemGenerator;

# Set as a global, with default values
my $generator = SCP::ProblemGenerator->new();

=head1 SUBTESTS

=head2 Attribute tests

=cut

subtest 'Attribute tests' => sub {
	isa_ok($generator, 'SCP::ProblemGenerator');
	
	is ($generator->max_result, 10, 'Default max_result is 10');
	is ($generator->min_result, 0, 'Default min_result is 0');
	
	# There are no problems until generated
	is ($generator->count_possible_problems, 0, 'count_possible_problems before generate is 0');
	
};

=head2 Next result

Confirm that the next result returns correctly in various situations.

Overriding this routine lets a class work only on even or odd numbers or allows 
for fractions. For now, the next value is one more than the last one

=cut

subtest 'Next result' => sub {
	
	# Minimum result
	is ($generator->next_result(0), 1, 'Next result of 0 is 1');
	
	# Middle result
	is ($generator->next_result(5), 6, 'Next result of 5 is 6');

	# Greater than max result
	is ($generator->next_result(10), 11, 'Next result of 10 is 11');
	
};

subtest 'generate' => sub {
	my $to_2_generator = SCP::ProblemGenerator->new({ max_result => 2 });
	is ($to_2_generator->max_result, 2, 'max_result is set to 2');
	$to_2_generator->generate();
	my $possible_problems = $to_2_generator->possible_problems;
	my $expected_result = [ 
		{ 'problem' => '1 + 0', 'result' => 1 },
		{ 'problem' => '1 + 1', 'result' => 2 },
		{ 'problem' => '2 + 0', 'result' => 2 },
	];
	is_deeply($possible_problems, $expected_result, 'Generator to 2 returns correctly');

	my $to_5_generator = SCP::ProblemGenerator->new({ max_result => 5 });
	is ($to_5_generator->max_result, 5, 'max_result is set to 5');
	$to_5_generator->generate();
	$possible_problems = $to_5_generator->possible_problems;
	$expected_result = [ 
		{ 'problem' => '1 + 0', 'result' => 1 },
		{ 'problem' => '1 + 1', 'result' => 2 },
		{ 'problem' => '2 + 0', 'result' => 2 },
		{ 'problem' => '1 + 2', 'result' => 3 },
		{ 'problem' => '2 + 1', 'result' => 3 },
		{ 'problem' => '3 + 0', 'result' => 3 },
		{ 'problem' => '1 + 3', 'result' => 4 },
		{ 'problem' => '2 + 2', 'result' => 4 },
		{ 'problem' => '3 + 1', 'result' => 4 },
		{ 'problem' => '4 + 0', 'result' => 4 },
		{ 'problem' => '1 + 4', 'result' => 5 },
		{ 'problem' => '2 + 3', 'result' => 5 },
		{ 'problem' => '3 + 2', 'result' => 5 },
		{ 'problem' => '4 + 1', 'result' => 5 },
		{ 'problem' => '5 + 0', 'result' => 5 }
	];
	is_deeply($possible_problems, $expected_result, 'Generator to 5 returns correctly');
};

subtest 'print' => sub {
	my $to_2_generator = SCP::ProblemGenerator->new({ max_result => 2 });
	$to_2_generator->generate();
	is ($to_2_generator->count_possible_problems, 3, 'count_possible_problems for a max result of 2 is 3');
	lives_ok { $to_2_generator->print(); } "Generator data printed, please visually confirm result";
};

subtest 'negative numbers' => sub {
	my $negative_numbers = SCP::ProblemGenerator->new({ min_result => -2, max_result => 2 });
	$negative_numbers->generate();
	is ($negative_numbers->count_possible_problems, 10, 'count_possible_problems for -2 to 2 is 10');
	my $possible_problems = $negative_numbers->possible_problems;
	my $expected_result = [
       { 'problem' => '1 + -3', 'result' => -2 },
       { 'problem' => '2 + -4', 'result' => -2 },
       { 'problem' => '1 + -2', 'result' => -1 },
       { 'problem' => '2 + -3', 'result' => -1 },
       { 'problem' => '1 + -1', 'result' => 0 },
       { 'problem' => '2 + -2', 'result' => 0 },
       { 'problem' => '1 + 0', 'result' => 1 },
       { 'problem' => '2 + -1', 'result' => 1 },
       { 'problem' => '1 + 1', 'result' => 2 },
       { 'problem' => '2 + 0', 'result' => 2 }
	];
	is_deeply($possible_problems, $expected_result, 'Generator to 5 returns correctly');
};

done_testing;
