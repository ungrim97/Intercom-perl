use Test::Most tests => 1;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::User;

subtest 'scroll users' => sub {
    plan tests => 2;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('get', sub {
        my ($self, $uri) = @_;

        is($uri, '/users/scroll', 'value of _user_path correctly passed to RH->get()');
        return 'test';
    });

    my $user = Intercom::Client::User->new(request_handler => $request_handler);

    is($user->scroll(), 'test', 'Correct response returned');
};
