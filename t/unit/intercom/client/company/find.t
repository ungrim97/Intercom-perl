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

        my $error = $companies->find();
        is($error->errors->[0]{code}, 'parameter_not_found', 'Missing param error returned');
    };

    subtest 'company_id && name param' => sub {
        plan tests => 1;

        $companies->request_handler->mock('get', sub {
            fail('Called through to RH->get()');
        });
        $companies->mock(_company_path => sub {
            fail('Called through to _company_path');
        });

        my $error = $companies->find({company_id => 1, name => 'test'});
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

    subtest 'with company_id' => sub {
        plan tests => 3;

        $companies->request_handler->mock('get', sub {
            my ($self, $uri) = @_;

            is($uri, '/companies?company_id=25', 'value of _company_path correctly passed to RH->get()');
            return 'test';
        });
        $companies->mock(_company_path => sub {
            my ($self, $params) = @_;

            cmp_deeply($params, {company_id => 25}, 'Passed company_id through to _company_path');

            return '/companies?company_id=25';
        });

        is($companies->find({company_id => 25}), 'test', 'Correct response returned using company_id identifier');
    };

    subtest 'with name' => sub {
        plan tests => 3;

        $companies->request_handler->mock('get', sub {
            my ($self, $uri) = @_;

            is($uri, '/companies?name=testname', 'value of _company_path correctly passed to RH->get()');
            return 'test';
        });
        $companies->mock(_company_path => sub {
            my ($self, $params) = @_;

            cmp_deeply($params, {name => 'testname'}, 'Passed name through to _company_path');

            return '/companies?name=testname';
        });

        is($companies->find({name => 'testname'}), 'test', 'Correct response returned using name identifier');
    };
};
