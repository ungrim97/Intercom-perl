use Test::Most tests => 1;
use Test::MockObject;

use Intercom::Client::User;

subtest 'request successful' => sub {
    plan tests => 3;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('post', sub {
        my ($self, $uri, $content) = @_;

        is($uri, '/users', 'correct uri passed to RH->post()');
        cmp_deeply($content, {email => 'test@test.com'} , 'Content passed through to RH->post()');

        return 'test'
    });

    my $users = Intercom::Client::User->new(request_handler => $request_handler);

    is($users->create({email => 'test@test.com'}), 'test', 'Correct response returned');
};
