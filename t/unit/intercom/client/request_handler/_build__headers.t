use Test::Most tests => 1;

use Intercom::Client::RequestHandler;

my $request_handler = Intercom::Client::RequestHandler->new(
    access_token => 'test',
    ua           => 'test',
    base_url     => 'test',
);

subtest 'access token' => sub {
    my $headers = $request_handler->_build__headers();

    my $expected = [
        'Accept'           => 'application/json',
        'Content-type'     => 'application/json',
        'Authorization'    => 'Bearer test',
        'Intercom-Version' => '1.1'
    ];

    cmp_deeply($headers, $expected, 'Headers correct');
};
