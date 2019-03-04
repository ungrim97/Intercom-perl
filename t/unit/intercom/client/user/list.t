use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::User;

subtest 'without params' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/users', 'value of _user_path correctly passed to RH->get()');
        return 'test';
    });

    my $user = Intercom::Client::User->new(request_handler => $request_handler);

    is($user->list(), 'test', 'Correct response returned');
};

subtest 'with params' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/users?page=2&per_page=30&sort=last_request_at', 'value of _user_path correctly passed to RH->get()');
        return 'test';
    });

    my $user = Intercom::Client::User->new(request_handler => $request_handler);

    is($user->list({per_page => 30, page => 2, sort => 'last_request_at'}), 'test', 'Correct response returned');
};
