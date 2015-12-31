use strictures 1;

=head1 NAME

PuzzleGenerator Testing

=head1 DESCRIPTION

Unit testing for PuzzleGenerator role.

=head1 AUTHOR

Katherine Curtis

=head1 COPYRIGHT

Katherine Curtis

=cut

use Test::Most;
use Try::Tiny;

use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

use SCP::PuzzleGenerator;

# Set as a global, with default values
my $data_dir = "$Bin/../../data/";

=head1 SUBTESTS

=head2 Attribute tests

=cut

subtest 'Attribute tests' => sub {
	my $puzzle_config = $data_dir . "puzzle-numbers01.dat";
	my $puzzle = SCP::PuzzleGenerator->new({ config_datafile => $puzzle_config });
	isa_ok($puzzle, 'SCP::PuzzleGenerator');
	
	is ($puzzle->config_datafile, $puzzle_config, 'Datafile file is specified');
	is ($puzzle->data_dir, $data_dir, 'Data directory is identified correctly');
	my $expected_meta = {
		'answer' => 'Cars have four wheels',
		'author' => 'K.Curtis',
		'category' => 'Addition to 10',
		'formulas' => 'addition_to_10.dat',
		'question' => 'How many wheels do cars have?',
		'title' => 'Cars',
	};
	is_deeply ($puzzle->puzzle_meta, $expected_meta, 'Meta data is correct');
	
	is ($puzzle->main_problem_datafile, $data_dir . 'addition_to_10.dat', 'Datafile is file specified');
	
	is ($puzzle->phrase_clue, 'How many wheels do cars have?', 'Clue is correct');
	is ($puzzle->phrase_answer, 'Cars have four wheels', 'Answer is correct');
	my @expected_required_letters = qw/A C E F H L O R S U V W/;
	is_deeply ($puzzle->required_letters, \@expected_required_letters, 'Required letters are correct');
	
	lives_ok { $puzzle->generate() } "Puzzle generates ok";
	# Confirm Letter Key
	my $letter_key = $puzzle->letter_key;
	my @letter_key_keys = sort keys $letter_key;
	is_deeply (\@letter_key_keys, \@expected_required_letters, 'Keys of the letter key match the required letters');
	
	# Confirm problem array
	my $problems = $puzzle->problems;
	is (scalar @$problems, scalar @expected_required_letters, "Correct number of problems generated");
	
	# Confirm answer format
	my $answer_format = $puzzle->answer_format;
	# Ensure that each line has the right number of chars
	is (scalar @{$answer_format->[0]}, 14, 'First line has 14 chars');
	is (scalar @{$answer_format->[1]}, 6, 'Second line has 6 chars');
	# Ensure the spaces are in the right place
	is ($answer_format->[0]->[4], ' ', "First space is in the right spot");
	is ($answer_format->[0]->[9], ' ', "Second space is in the right spot");
	isnt ($answer_format->[0]->[0], ' ', "First line does not start with a space");
	isnt ($answer_format->[1]->[0], ' ', "Second line does not start with a space");
};

done_testing;
