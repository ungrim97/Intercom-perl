use Test::Most tests => 1;
use Test::MockObject::Extends;

use Intercom::Client::RequestHandler;

subtest 'URI pass through' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject::Extends->new(
        Intercom::Client::RequestHandler->new(
            base_url   => 'test',
            access_token => 'test',
            ua         => 'test',
        )
    );

    $request_handler->mock(_send_request => sub {
        my ($self, $method, $uri) = @_;

        is($method, 'GET', 'Correct method');
        is($uri, '/users', 'Correct URI');
    });

    $request_handler->get(URI->new('/users'));
};
