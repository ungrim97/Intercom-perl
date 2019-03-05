use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::RequestHandler;

my $request_handler = Test::MockObject::Extends->new(
    Intercom::Client::RequestHandler->new(
        access_token => 'test',
        ua           => 'test',
        base_url     => 'test'
    )
);
$request_handler->mock(_deserialise_body => sub { return $_[1] });

subtest 'no content' => sub {
    plan tests => 1;

    my $response = Test::MockObject->new();
    $response->mock(content => sub { return undef });

    my $resource = $request_handler->_manage_response($response);
    is($resource, undef, 'No resource returned for null content');
};

subtest 'content' => sub {
    plan tests => 3;

    my $request = Test::MockObject->new();
    $request->mock(url => sub { return 'testURL' });

    my $response = Test::MockObject->new();
    $response->mock(content => sub { return 'testContent' });
    $response->mock(request => sub { return $request });

    $request_handler->mock(_transform_resource_data => sub {
        my ($self, $response_data, $request_url) = @_;

        is($response_data, 'testContent', 'response content passed to _transform_resource_data');
        is($request_url, 'testURL', 'request url passed through to _transform_resource_data');

        return 'testResource';
    });

    my $resource = $request_handler->_manage_response($response);
    is($resource, 'testResource', 'No resource returned for null content');
};
