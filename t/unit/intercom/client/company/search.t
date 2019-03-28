use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::Company;

subtest 'Errors' => sub {
    plan tests => 2;

    my $companies = Test::MockObject::Extends->new(
        Intercom::Client::Company->new(
            request_handler => Test::MockObject->new()
        )
    );

    subtest 'no identification param' => sub {
        plan tests => 1;

        $companies->request_handler->mock('get', sub {
            fail('Called through to RH->get()');
        });
        $companies->mock(_company_path => sub {
            fail('Called through to _company_path');
        });

        my $error = $companies->search();
        is($error->errors->[0]{code}, 'parameter_not_found', 'Missing param error returned');
    };

    subtest 'tag_id && segment_id param' => sub {
        plan tests => 1;

        $companies->request_handler->mock('get', sub {
            fail('Called through to RH->get()');
        });
        $companies->mock(_company_path => sub {
            fail('Called through to _company_path');
        });

        my $error = $companies->search({tag_id => 1, segment_id => 'test'});
        is($error->errors->[0]{code}, 'parameter_invalid', 'Invalid param error returned');
    };
};

subtest 'request successful' => sub {
    plan tests => 2;

    my $companies = Test::MockObject::Extends->new(
        Intercom::Client::Company->new(
            request_handler => Test::MockObject->new()
        )
    );

    subtest 'with tag_id' => sub {
        plan tests => 3;

        $companies->request_handler->mock('get', sub {
            my ($self, $uri) = @_;

            is($uri, '/companies?tag_id=25', 'value of _company_path correctly passed to RH->get()');
            return 'test';
        });
        $companies->mock(_company_path => sub {
            my ($self, $params) = @_;

            cmp_deeply($params, {tag_id => 25}, 'Passed tag_id through to _company_path');

            return '/companies?tag_id=25';
        });

        is($companies->search({tag_id => 25}), 'test', 'Correct response returned using tag_id identifier');
    };

    subtest 'with segment_id' => sub {
        plan tests => 3;

        $companies->request_handler->mock('get', sub {
            my ($self, $uri) = @_;

            is($uri, '/companies?segment_id=testsegment_id', 'value of _company_path correctly passed to RH->get()');
            return 'test';
        });
        $companies->mock(_company_path => sub {
            my ($self, $params) = @_;

            cmp_deeply($params, {segment_id => 'testsegment_id'}, 'Passed segment_id through to _company_path');

            return '/companies?segment_id=testsegment_id';
        });

        is($companies->search({segment_id => 'testsegment_id'}), 'test', 'Correct response returned using segment_id identifier');
    };
};
