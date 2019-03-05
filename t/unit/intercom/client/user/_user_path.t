use Test::Most tests => 4;
use Test::MockObject;

use Intercom::Client::User;
my $user_client = Intercom::Client::User->new(request_handler => Test::MockObject->new());

subtest 'ID param' => sub {
    plan tests => 1;

    my $uri = $user_client->_user_path({id => 1});

    is($uri->as_string, '/users/1', 'constructed uri for id');
};

subtest 'Email param' => sub {
    plan tests => 1;

    my $uri = $user_client->_user_path({email => 'test@test.com'});

    is($uri->as_string, '/users?email=test%40test.com', 'constructed uri for id');
};

subtest 'User id param' => sub {
    plan tests => 1;

    my $uri = $user_client->_user_path({user_id => 1});

    is($uri->as_string, '/users?user_id=1', 'constructed uri for id');
};

subtest 'no param' => sub {
    plan tests => 1;

    throws_ok(
        sub {$user_client->_user_path()},
        qr/No \[id\], \[email\] or \[user_id\] provided to identify user/,
        'throws without param'
    );
};
