use Test::Most tests => 1;
use Test::MockObject::Extends;

use Intercom::Client::RequestHandler;

subtest '_send_request' => sub {
    my $mock_ua = Test::MockObject->new();
    $mock_ua->mock(request => sub {
        my ($self, $request) = @_;

        is($request, 'testRequest', 'Request passed to UA->request');
        return 'testResponse'
    });

    my $request_handler = Test::MockObject::Extends->new(
        Intercom::Client::RequestHandler->new(
            access_token => 'test',
            ua           => $mock_ua,
            base_url     => 'test',
        )
    );

    $request_handler->mock(_build_request => sub {
        my ($self, $method, $uri, $body) = @_;

        is($method, 'testMethod', 'Method passed to ->_build_request');
        is($uri, 'testURI', 'Method passed to ->_build_request');
        is($body, 'testBody', 'Method passed to ->_build_request');

        return 'testRequest'
    });
    $request_handler->mock(_handle_response => sub {
        my ($self, $response) = @_;

        is($response, 'testResponse', 'Response passed to ->_handle_response');
    });

    $request_handler->_send_request('testMethod', 'testURI', 'testBody');
};

