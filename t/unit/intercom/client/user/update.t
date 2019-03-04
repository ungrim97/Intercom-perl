use Test::Most tests => 2;
use Test::MockObject;
use Test::MockObject::Extends;

use Intercom::Client::User;

subtest 'no identification param' => sub {
    plan tests => 1;

    my $users = Test::MockObject::Extends->new(
        Intercom::Client::User->new(request_handler => Test::MockObject->new())
    );
    $users->mock(create => sub {
        fail('Create called');
    });

    my $error = $users->update({});
    is($error->errors->[0]{code}, 'parameter_not_found', 'Missing param error thrown');
};

subtest 'request successful' => sub {
    plan tests => 3;

    my $users = Test::MockObject::Extends->new(
        Intercom::Client::User->new(request_handler => Test::MockObject->new())
    );

    subtest 'with email' => sub {
        plan tests => 2;

        $users->mock(create => sub {
            my ($self, $user_data) = @_;

            cmp_deeply($user_data, {email => 'test@test.com'}, 'User data passed through to User->create()');

            return 'test';
        });

        is($users->update({email => 'test@test.com'}), 'test', 'Correct response returned using email identifier');
    };

    subtest 'with user_id' => sub {
        plan tests => 2;

        $users->mock(create => sub {
            my ($self, $user_data) = @_;

            cmp_deeply($user_data, {user_id => 25}, 'User data passed through to User->create()');

            return 'test';
        });

        is($users->update({user_id => 25}), 'test', 'Correct response returned using user_id identifier');
    };

    subtest 'with id' => sub {
        plan tests => 2;

        $users->mock(create => sub {
            my ($self, $user_data) = @_;

            cmp_deeply($user_data, {id => 1}, 'User data passed through to User->create()');

            return 'test';
        });

        is($users->update({id => 1}), 'test', 'Correct response returned using id identifier');
    };
};
