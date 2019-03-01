use Test::Most tests => 1;
use Try::Tiny;

use Intercom::Client;

subtest 'require auth token' => sub {
    plan tests => 2;

    try {
        return Intercom::Client->new();
    } catch {
        ok($_, 'Failed to create Client without auth token');
    };

    ok(Intercom::Client->new(auth_token => 'token'), 'Client created successfully with token');
};
