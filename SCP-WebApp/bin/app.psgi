#!/usr/bin/env perl
use strict;
use warnings;

=head1 bin/app.psgi

This PSGI (Perl Server Gateway Interface) file is what is run to create the web
server. For details on PSGI please visit http://plackperl.org/.

To run the Web Server, use the following command:

	$ plackup -r bin/app.psgi 

This 'runs' the module at 'lib/SCP/WebApp.pm'

I have chosen to use the Dancer2 framework so make it easier to create and
maintain the PSGI application

=cut

use FindBin;
use lib "$FindBin::Bin/../lib";

use SCP::WebApp;
SCP::WebApp->to_app;
