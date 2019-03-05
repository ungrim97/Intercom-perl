use Test::Most tests => 5;
use Test::MockObject::Extends;
use Test::MockObject;

use Intercom::Client::RequestHandler;

my $request_handler = Test::MockObject::Extends->new(
    Intercom::Client::RequestHandler->new(
        access_token => 'test',
        ua           => 'test',
        base_url     => 'test'
    )
);

subtest 'No Resource data' => sub {
    plan tests => 1;

    my $resource = $request_handler->_transform_resource_data();

    is($resource, undef, 'No data in == No data out');
};

subtest 'String resource data' => sub {
    plan tests => 1;

    my $resource = $request_handler->_transform_resource_data('string');

    is($resource, 'string', 'String in == String out');
};

subtest 'Array resource data' => sub {
    plan tests => 3;

    my $input_resource = ['test'];
    $request_handler->mock(_construct_resource_list => sub {
        my ($self, $resource_data, $request_url) = @_;

        cmp_deeply($resource_data, $input_resource, 'resource_data passed through to _construct_resource_list');
        is($request_url, 'test', 'request_url passed through to _contruct_resource_list');

        return $resource_data;
    });

    my $resource = $request_handler->_transform_resource_data($input_resource, 'test');

    is($resource, $input_resource, 'Array in == Array out');

    $request_handler->unmock('_construct_resource_list');
};

subtest 'Hash resource data' => sub {
    plan tests => 3;

    my $input_resource = {'testkey' => 'testvalue'};
    $request_handler->mock(_construct_resource => sub {
        my ($self, $resource_data, $request_url) = @_;

        cmp_deeply($resource_data, $input_resource, 'resource_data passed through to _construct_resource');
        is($request_url, 'test', 'request_url passed through to _contruct_resource');

        return $resource_data;
    });

    my $resource = $request_handler->_transform_resource_data($input_resource, 'test');

    is($resource, $input_resource, 'Hash in == Hash out');

    $request_handler->unmock('_construct_resource');
};

subtest 'Object resource data' => sub {
    plan tests => 1;

    my $input_data = Test::MockObject->new();

    my $resource = $request_handler->_transform_resource_data($input_data);

    is($resource, $input_data, 'Object in == Object out');
};
