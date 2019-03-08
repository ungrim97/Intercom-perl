use Test::Most tests => 3;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::User;

subtest 'By email' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/users?email=test%40test.com', 'value of _user_path correctly passed to RH->search()');
        return 'test';
    });

    my $user = Test::MockObject::Extends->new(
        Intercom::Client::User->new(request_handler => $request_handler)
    );
    $user->mock(_user_path => sub {
        my ($self, $params) = @_;

        cmp_deeply($params, {email => 'test@test.com'}, 'Passed email through to _user_path');

        return '/users?email=test%40test.com';
    });

    is($user->search({email => 'test@test.com'}), 'test', 'Correct response returned');
};

subtest 'By user_id' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/users?user_id=2', 'value of _user_path correctly passed to RH->search()');
        return 'test';
    });

    my $user = Test::MockObject::Extends->new(
        Intercom::Client::User->new(request_handler => $request_handler)
    );
    $user->mock(_user_path => sub {
        my ($self, $params) = @_;

        cmp_deeply($params, {user_id => '2'}, 'Passed email through to _user_path');

        return '/users?user_id=2';
    });

    is($user->search({user_id => 2}), 'test', 'Correct response returned');
};

subtest 'Missing params' => sub {
    plan tests => 1;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        fail('Called RH->get');
    });

    my $user = Test::MockObject::Extends->new(
        Intercom::Client::User->new(request_handler => $request_handler)
    );

    is(
        $user->search()->errors->[0]{code},
        'parameter_not_found',
        'Correct response returned'
    );
};
