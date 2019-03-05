use Test::Most tests => 2;
use Test::MockObject::Extends;
use URI;

use Intercom::Client::RequestHandler;

my $request_handler = Test::MockObject::Extends->new(
    Intercom::Client::RequestHandler->new(
        access_token => 'test',
        ua           => 'test',
        base_url     => URI->new('https://test.com'),
        _headers     => [],
    )
);

$request_handler->mock(_serialise_body => sub {
    return $_[1];
});

subtest 'Body' => sub {
    plan tests => 2;

    subtest 'body' => sub {
        plan tests => 4;

        my $request = $request_handler->_construct_request('GET', undef, 'testContent');

        is($request->method, 'GET', 'Request method set');
        is($request->content, 'testContent', 'No body set');
        is($request->uri->as_string, 'https://test.com', 'URL set');
        is($request->headers->as_string, '', 'No headers');
    };

    subtest 'no Body' => sub {
        plan tests => 4;

        my $request = $request_handler->_construct_request('GET');

        is($request->method, 'GET', 'Request method set');
        is($request->content, '', 'No body set');
        is($request->uri->as_string, 'https://test.com', 'URL set');
        is($request->headers->as_string, '', 'No headers');
    };
};

subtest 'URI' => sub {
    plan tests => 3;

    subtest 'no URI' => sub {
        plan tests => 4;

        my $request = $request_handler->_construct_request('GET');

        is($request->method, 'GET', 'Request method set');
        is($request->content, '', 'No body set');
        is($request->uri->as_string, 'https://test.com', 'URL set');
        is($request->headers->as_string, '', 'No headers');
    };

    subtest '- absolute URI' => sub {
        plan tests => 4;

        my $request = $request_handler->_construct_request('GET', URI->new('https://foo.com'));

        is($request->method, 'GET', 'Request method set');
        is($request->content, '', 'No body set');
        is($request->uri->as_string, 'https://foo.com', 'URL set');
        is($request->headers->as_string, '', 'No headers');
    };

    subtest '- relative URI' => sub {
        plan tests => 4;

        my $request = $request_handler->_construct_request('GET', URI->new('/test?foo=bar'));

        is($request->method, 'GET', 'Request method set');
        is($request->content, '', 'No body set');
        is($request->uri->as_string, 'https://test.com/test?foo=bar', 'URL set');
        is($request->headers->as_string, '', 'No headers');
    };
};
