
use Test::More tests => 1;

use Dancer2::Plugin::CDN;

ok(1, "Successfully loaded Dancer2::Plugin::CDN via 'use'");

diag( "Testing Dancer2::Plugin::CDN $Dancer2::Plugin::CDN::VERSION, Perl $], $^X" );
