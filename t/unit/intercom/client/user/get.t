use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::User;

subtest 'By ID' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/users/1', 'value of _user_path correctly passed to RH->get()');
        return 'test';
    });

    my $user = Test::MockObject::Extends->new(
        Intercom::Client::User->new(request_handler => $request_handler)
    );

    $user->mock(_user_path => sub {
        my ($self, $params) = @_;

        cmp_deeply($params, {id => 1}, 'Passed id through to _user_path');

        return '/users/1';
    });
    is($user->get(1), 'test', 'Correct response returned');
};

subtest 'missing id' => sub {
    plan tests => 1;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        fail('Called RH->get');
    });

    my $user = Intercom::Client::User->new(
        request_handler => $request_handler
    );

    is(
        $user->get()->errors->[0]->{code},
        'parameter_not_found',
        'Correct response returned'
    );
};

