use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::Company;

subtest 'By ID' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/companies/1', 'value of _company_path correctly passed to RH->get()');
        return 'test';
    });

    my $company = Test::MockObject::Extends->new(
        Intercom::Client::Company->new(request_handler => $request_handler)
    );

    $company->mock(_company_path => sub {
        my ($self, $params) = @_;

        cmp_deeply($params, {id => 1}, 'Passed id through to _company_path');

        return '/companies/1';
    });
    is($company->get(1), 'test', 'Correct response returned');
};

subtest 'missing id' => sub {
    plan tests => 1;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        fail('Called RH->get');
    });

    my $company = Intercom::Client::Company->new(
        request_handler => $request_handler
    );

    is(
        $company->get()->errors->[0]->{code},
        'parameter_not_found',
        'Correct response returned'
    );
};
