use Test::Most tests => 1;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::Company;

subtest 'scroll companies' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/companies/scroll', 'value of _company_path correctly passed to RH->get()');
        return 'test';
    });

    my $company = Intercom::Client::Company->new(request_handler => $request_handler);

    is($company->scroll(), 'test', 'Correct response returned');
};
