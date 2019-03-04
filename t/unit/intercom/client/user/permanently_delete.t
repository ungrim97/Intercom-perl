use Test::Most tests => 1;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::User;

subtest 'delete user' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('post', sub {
        my ($self, $uri, $body) = @_;

        is($uri, '/user_delete_requests', 'value of _user_path correctly passed to RH->post()');
        cmp_deeply($body, { intercom_user_id => 1 }, 'Correct params passed to RH->post()');
        return 'test';
    });

    my $user = Intercom::Client::User->new(request_handler => $request_handler);

    is($user->permanently_delete(1), 'test', 'Correct response returned');
};
