
use strict;
use warnings;

use Test::More import => ['!pass'];

my $test_root;
BEGIN {
    use Path::Class qw();
    $test_root = '' . Path::Class::dir('t', 'test-app', 'static');
}

{
    use Dancer;
    use Dancer::Plugin::CDN;

    setting(plugins => {
        CDN => {
            root    => $test_root,
            base    => '/CDN/',
            plugins => [ 'CSS' ],
        }
    });

    get '/status' => sub {
        return "OK";
    };

    get '/' => sub {
        return cdn_url( 'css/style.css' );
    };

    get '/page2' => sub {
        return cdn_url( 'css/style2.css' );
    };

}

use Dancer::Test;

route_exists [GET => '/status'], 'home page route';

response_status_is [GET => '/status'], 200;
response_content_is [GET => '/status'], 'OK';

my $resp = dancer_response(GET => '/');
is $resp->{status}, 200, 'GET / => status 200';
like $resp->{content}, qr{^/CDN/css/style[.][0-9A-F]{12}[.]css},
    'css/style.css rewritten to /CDN/css/style.<HASH>.css';
chomp(my $url = $resp->{content});

$resp = dancer_response(GET => $url);
is $resp->{status}, 200, "GET $url => status 200";
like $resp->{content}, qr/h1 { color: red; }/, 'css/style.css content';

$resp = dancer_response(GET => '/page2');
is $resp->{status}, 200, "GET /page2 => status 200";
like $resp->{content}, qr{^/CDN/css/style2[.][0-9A-F]{12}[.]css},
    'css/style.css rewritten to /CDN/css/style2.<HASH>.css';
chomp($url = $resp->{content});

$resp = dancer_response(GET => $url);
is $resp->{status}, 200, "GET $url => status 200";
like $resp->{content}, qr{images/logo[.][0-9A-F]{12}[.]png},
    'css/style2.css content';

$url =~ s/[.][0-9A-F]{12}[.]/.FFFFFFFFFFFF./;
$resp = dancer_response(GET => $url);
is $resp->{status}, 404, "GET $url => status 404";

done_testing;

