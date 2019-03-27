use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::Company;

subtest 'without params' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/companies', 'params correctly passed to RH->get()');
        return 'test';
    });

    my $company = Intercom::Client::Company->new(request_handler => $request_handler);

    is($company->list(), 'test', 'Correct response returned');
};

subtest 'with params' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/companies?page=2&per_page=30', 'params correctly passed to RH->get()');
        return 'test';
    });

    my $company = Intercom::Client::Company->new(request_handler => $request_handler);

    is($company->list({per_page => 30, page => 2}), 'test', 'Correct response returned');
};
