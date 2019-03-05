use Test::Most tests => 1;
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

subtest 'create' => sub {
    plan tests => 4;

    my $request_url = Test::MockObject->new();
    $request_url->mock(clone => sub { return shift });
    $request_url->mock(query_param_append => sub {
        my ($self, $param_name, $param_value) = @_;

        is($param_name, 'scroll_param', 'Correct query param name passed to URI->query_param_append');
        is($param_value, 'testScrollParam', 'Correct query param value passed to URI->query_param_append');
    });

    $request_handler->mock('_construct_paginator' => sub {
        my ($self, $paginator_data) = @_;

        cmp_deeply($paginator_data, {next => $request_url}, 'Request url passed to ->_construct_paginator');

        return Test::MockObject->new($paginator_data);
    });

    my $paginator = $request_handler->_construct_scrollable_paginator('testScrollParam', $request_url);
    is($paginator->{next} => $request_url, 'Set next url on object');
};
