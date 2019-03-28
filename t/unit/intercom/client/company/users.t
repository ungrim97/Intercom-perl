use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::Company;

subtest 'Errors' => sub {
    plan tests => 1;

    my $request_handler = Test::MockObject->new();
    my $companies = Test::MockObject::Extends->new(
        Intercom::Client::Company->new({request_handler => $request_handler})
    );

    subtest 'No Company_id' => sub {
        plan tests => 1;

        $request_handler->mock(get => sub {
            fail('Called through to RH->get()');
        });
        $companies->mock(_company_path => sub {
            fail('Called through to ->_company_path');
        });

        my $response = $companies->users();
        is($response->errors->[0]{code}, 'parameter_not_found', 'Error returned');
    };
};

subtest 'Request' => sub {
    plan tests => 1;

    my $request_handler = Test::MockObject->new();
    my $companies = Test::MockObject::Extends->new(
        Intercom::Client::Company->new({request_handler => $request_handler})
    );

    subtest 'get' => sub {
        plan tests => 3;

        $request_handler->mock(get => sub {
            my ($self, $uri) = @_;

            is($uri->as_string, '/companies?company_id=1234&type=user', 'URI passed to RH->get');
            return 'test'
        });
        $companies->mock(_company_path => sub {
            my ($self, $params) = @_;

            cmp_deeply($params, {company_id => 1234}, 'Passed through company_id to ->_company_path');
            return URI->new('/companies?company_id=1234');
        });

        my $response = $companies->users(1234);
        is($response, 'test', 'Response returned');
    };
};
