#!/usr/bin/env perl
use strict;
use warnings;

=head1 bin/app.psgi

This PSGI (Perl Server Gateway Interface) file is what is run to create the web
server. For details on PSGI please visit http://plackperl.org/.

This is setup to be run from a Docker environment. To build and run from Docker

	$ sudo service docker start                  # Ensure docker is running
	$ sudo docker build . -t puzzle:00001        # Where 00001 is the image number and should increment
	$ sudo docker run -p 80:50000 puzzle:00001   # This runs the docker container

Your app should now be available on port 80

This 'runs' the module at 'lib/SCP/WebApp.pm'

I have chosen to use the Dancer2 framework so make it easier to create and
maintain the PSGI application

=cut

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "/opt/app/lib";

use SCP::WebApp;
SCP::WebApp->to_app;
