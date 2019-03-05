use Test::Most tests => 1;
use Test::MockObject::Extends;

use Intercom::Client::RequestHandler;

subtest 'pass through' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject::Extends->new(
        Intercom::Client::RequestHandler->new(
            base_url   => 'test',
            access_token => 'test',
            ua         => 'test',
        )
    );

    $request_handler->mock(_send_request => sub {
        my ($self, $method, $uri, $body) = @_;

        is($method, 'DELETE', 'Correct method');
        is($uri, '/users', 'Correct URI');
        cmp_deeply($body, {test => 'data'}, 'body data passed through');
    });

    $request_handler->delete(URI->new('/users'), {test => 'data'});
};
