use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::Company;

subtest 'no identification param' => sub {
    plan tests => 1;

    my $companies = Test::MockObject::Extends->new(
        Intercom::Client::Company->new(request_handler => Test::MockObject->new())
    );
    $companies->mock(create => sub {
        fail('Create called');
    });

    my $error = $companies->update({});
    is($error->errors->[0]{code}, 'parameter_not_found', 'Missing param error thrown');
};

subtest 'request successful' => sub {
    plan tests => 1;

    my $companies = Test::MockObject::Extends->new(
        Intercom::Client::Company->new(request_handler => Test::MockObject->new())
    );

    subtest 'with company_id' => sub {
        plan tests => 2;

        $companies->mock(create => sub {
            my ($self, $company_data) = @_;

            cmp_deeply($company_data, {company_id => 25}, 'Company data passed through to Company->create()');

            return 'test';
        });

        is($companies->update({company_id => 25}), 'test', 'Correct response returned using company_id identifier');
    };
};
