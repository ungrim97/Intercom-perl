use Test::Most tests => 1;
use Test::MockObject::Extends;

use Intercom::Client::RequestHandler;

my $request_handler = Test::MockObject::Extends->new(
    Intercom::Client::RequestHandler->new(
        access_token => 'test',
        ua           => 'test',
        base_url     => 'test'
    )
);

subtest 'convert to uri' => sub {
    plan tests => 5;

    my $test_data = {
        next => 'https://test.com/next',
        prev => 'https://test.com/prev',
        first => 'https://test.com/first',
        last => 'https://test.com/last',
    };
    my $paginator = $request_handler->_construct_paginator($test_data);

    is($paginator->{next}->as_string, $test_data->{next}, 'next url converted to URI object');
    is($paginator->{prev}->as_string, $test_data->{prev}, 'prev url converted to URI object');
    is($paginator->{first}->as_string, $test_data->{first}, 'first url converted to URI object');
    is($paginator->{last}->as_string, $test_data->{last}, 'last url converted to URI object');
    cmp_deeply($paginator->{request_handler}, $request_handler, 'set request handler on paginator');
};
