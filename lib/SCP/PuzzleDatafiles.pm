package SCP::PuzzleDatafiles;
use Moose;

use File::Slurp;
use JSON::XS;
use Try::Tiny;

has data_dir => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_data_dir');

sub _build_data_dir
{
	my $self = shift;

	# This is hard coded and controled by Docker
	return "/opt/app/data/";
}

has json_coder => (is => 'ro', lazy => 1, builder => '_build_json_coder');

sub _build_json_coder
{
	my $self = shift;

        my $json_coder = JSON::XS->new;
        $json_coder->relaxed(1);
        $json_coder->utf8(1);
}

sub get_datafile_config
{
	my $self = shift;

	my $data_dir        = $self->data_dir;
	my $config_datafile = $data_dir . "formula_files.json";

	die "Config ($config_datafile) file doesn't exist" unless (-e $config_datafile);

	my $json_coder   = $self->json_coder;
	my $config_json = read_file($config_datafile);
	my $datafile_config;
	try {
		$datafile_config = $json_coder->decode($config_json);
	}
	catch {
		warn "Failed to open configuration: $config_datafile. Due to $_";
	};
}

sub get_datafile_list
{
	my $self = shift;

	my $datafile_config = $self->get_datafile_config();

	my @datafiles;
	foreach my $category (keys %$datafile_config) {
		my $category_datafiles = $datafile_config->{$category}->{datafiles};
		foreach my $datafile_data (@$category_datafiles) {
			push (@datafiles, $datafile_data->{datafile});
		}
	}
	return \@datafiles;
}

1;
