package SCP::WebApp;
use Dancer2;
use Template;

use FindBin qw/$Bin/;
use lib "$Bin/../../lib";

use SCP::PuzzleGenerator;

our $VERSION = '0.1';

=head1 ROUTES

=head2 GET /

Default route. The index page. Currently left untouched

=cut

get '/' => sub {
	template 'index';
};

=head2 GET /puzzle

Prompt the user with the puzzle form. This form will be submitted to

	POST /puzzle

TODO: Generate lists of valid formula datafiles and provide select
options rather than requiring the users to magically know

=cut 

get '/puzzle' => sub {
    template 'puzzle-form';
};

=head2 POST /puzzle

Generate the pdf output data based on the user's inputs and return the pdf file.

TODO: Save the pdf file and make it available for download

=cut

post '/puzzle' => sub {
	my $puzzle_generator_config;
	foreach my $param (qw(title category formulas question answer author)) {
		$puzzle_generator_config->{$param} = param($param);
	}
	
	my $puzzle = SCP::PuzzleGenerator->new(puzzle_meta => $puzzle_generator_config);
	my $template_vars = $puzzle->generate();

	my $template_config = {
		INCLUDE_PATH    => [ $puzzle->data_dir . "../" ],
	};
	my $temporary_file = $puzzle->_temp_file_name('.tex');
	my $tt = Template->new($template_config);
	$tt->process('puzzle.tt', $template_vars, $temporary_file) || die $tt->error();;
	my $dispatcher = $puzzle->get_dispatcher('pdf');
	$dispatcher->($temporary_file);
	(my $output_file = $temporary_file) =~ s/\.tex$/.pdf/;
	send_file($output_file, system_path => 1);
};

true;
