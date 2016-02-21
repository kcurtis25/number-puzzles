#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use SCP::WebApp;
SCP::WebApp->to_app;
