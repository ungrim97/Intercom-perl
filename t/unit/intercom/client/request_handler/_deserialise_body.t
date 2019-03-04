use Test::Most tests => 2;

use Intercom::Client::RequestHandler;

my $request_handler = Intercom::Client::RequestHandler->new(
    access_token => 'test',
    ua           => 'test',
    base_url     => URI->new('https://test.com')
);

subtest 'no body' => sub {
    plan tests => 1;

    my $deserialised_body = $request_handler->_deserialise_body();

    is($deserialised_body, undef, 'No op');
};

subtest 'body' => sub {
    plan tests => 1;

    my $deserialised_body = $request_handler->_deserialise_body('{"id": 1}');

    cmp_deeply($deserialised_body, {id => 1}, 'Deserialised_body');
};
