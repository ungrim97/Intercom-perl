use Test::Most tests => 3;
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

subtest 'scroll_param' => sub {
    plan tests => 3;

    $request_handler->mock(_construct_scrollable_paginator => sub {
        my ($self, $scroll_param, $request_url) = @_;

        is($scroll_param, 'testScrollParam', 'scroll_param value passed to _construct_scrollable_paginator');
        is($request_url, 'testURL', 'request url passed to _construct_scrollable_paginator');

        return $request_url.$scroll_param;
    });

    my $resource = $request_handler->_construct_resource({ scroll_param => 'testScrollParam' }, 'testURL');
    cmp_deeply($resource, { pages => 'testURLtestScrollParam' }, 'Resource transformed');

    $request_handler->unmock('_construct_scrollable_paginator');
};

subtest 'pages' => sub {
    plan tests => 2;

    $request_handler->mock(_construct_paginator => sub {
        my ($self, $page_data) = @_;

        is($page_data, 'testPage', 'pages value passed to _construct_paginator');

        return $page_data.'_transformed';
    });

    my $resource = $request_handler->_construct_resource({ pages => 'testPage' }, 'testURL');
    cmp_deeply($resource, { pages => 'testPage_transformed' }, 'Resource transformed');

    $request_handler->unmock('_construct_paginator');
};

subtest 'resource' => sub {
    plan tests => 2;

    $request_handler->mock(_transform_resource_data => sub {
        my ($self, $data) = @_;

        is($data, 'testData', 'resource data value passed to _transform_resource_data');

        return $data.'_transformed';
    });

    subtest 'typed' => sub {
        plan tests => 5;

        $request_handler->mock(_type_to_resource => sub {
            my ($self, $type) = @_;

            is($type, 'testType', 'type passed to ->_type_to_resource');

            return 'Test::MockObject';
        });

        my $resource = $request_handler->_construct_resource({ type => 'testType', data => 'testData' }, 'testURL');

        is(ref $resource, 'Test::MockObject', 'Resource constructed from resource data');

        is($resource->{type}, undef, 'type not passed to constructor');
        is($resource->{data}, 'testData_transformed', 'data transformed');

        $request_handler->unmock('_type_to_resource');
    };

    subtest 'untyped' => sub {
        plan tests => 2;

        my $resource = $request_handler->_construct_resource({ data => 'testData' }, 'testURL');
        cmp_deeply($resource, { data => 'testData_transformed' }, 'Resource transformed');
    };

    $request_handler->unmock('_transform_resource_data');
};

