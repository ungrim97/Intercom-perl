use Test::Most tests => 1;
use Test::MockObject;
use HTTP::Response;

use Intercom::Client::User;

subtest 'request successful' => sub {
    plan tests => 1;

    my $request_handler = Test::MockObject->new();
    $request_handler->mock('post', sub { return _mock_response(); });

    my $users = Intercom::Client::User->new(request_handler => $request_handler);

    cmp_deeply($users->permanently_delete({email => 'test@test.com'}), _mock_response(), 'Correct response returned');
};

sub _mock_response {
    return {
		"type"      => "user",
		"id"        => "5714dd359a3fd47136000001",
		"user_id"   => "25",
		"anonymous" => 0,
		"email"     => "wash\@serenity.io",
		"phone"     => "555671243",
		"name"      => "Hoban Washburne",
		"pseudonym" => undef,
    };
}
