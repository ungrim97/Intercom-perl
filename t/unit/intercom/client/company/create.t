use Test::Most tests => 1;
use Test::MockObject;

use Intercom::Client::Company;

subtest 'request successful' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('post', sub {
        my ($self, $uri, $content) = @_;

        is($uri, '/companies', 'correct uri passed to RH->post()');
        cmp_deeply($content, {company_id => 1234, name => 'Test comp'} , 'Content passed through to RH->post()');

        return 'test'
    });

    my $companies = Intercom::Client::Company->new(request_handler => $request_handler);

    is($companies->create({company_id => 1234, name => 'Test comp'}), 'test', 'Correct response returned');
};
