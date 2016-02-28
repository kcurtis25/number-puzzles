use strict;
use warnings;

use SCP::WebApp;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

my $app = SCP::WebApp->to_app;
is( ref $app, 'CODE', 'Got app' );
my $test = Plack::Test->create($app);
my $res;

# Test the GET index route
$res  = $test->request( GET '/' );
ok( $res->is_success, '[GET /] successful' );

# Test the GET puzzle route
$res  = $test->request( GET '/puzzle' );
ok( $res->is_success, '[GET /puzzle] successful' );

done_testing;
