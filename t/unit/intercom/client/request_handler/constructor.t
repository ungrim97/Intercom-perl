use Test::Most tests => 1;
use Test::MockObject;
use Try::Tiny;

use Intercom::Client::RequestHandler;

subtest 'require auth_token' => sub {
    plan tests => 2;

    my $params = {
        ua       => Test::MockObject->new(),
        base_url => Test::MockObject->new(),
    };

    try {
        return Intercom::Client::RequestHandler->new($params);
    } catch {
        ok($_, 'Failed to create Client without auth token');
    };

    ok(
        Intercom::Client::RequestHandler->new({ %$params, auth_token => 'token' }),
        'Client created successfully with token'
    );
};
