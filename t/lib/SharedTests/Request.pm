package SharedTests::Request;

use Test::Most;
use Test::Mock::LWP::Dispatch;

=head1 NAME

SharedTests::Request - Shared test functionality for request handling

=head1 SYNOPSIS

    use Test::Most;
    use SharedTests::Request;

    SharedTests::Request::auth_failure(sub {
        return shift->users->get({id => 1});
    });

    subtest 'My other tests' => sub {};

=head1 DESCRIPTION

A utility module containing shared integration tests that are needed by most specific resource
tests to ensure that they all use the correct code paths.

This module contains shared tests as they relate to the handling of specific request scenarios
(auth failure etc)

=head2 FUNCTIONS

=head2 auth_failure (function $call) -> undef

Attempts to test the functionallity of $call when run on a client that
has an invalid auth token

Takes a function ref that will recieve a mocked Intercom::Client object
and should return the result of a resource call (i.e $mock_client->users->get())

    SharedTests::Request::auth_failure(sub {
        return shift->users->get({id => 1});
    });

=cut

sub auth_failure {
    my ($call) = @_;

    subtest 'auth failure' => sub {
        plan tests => 2;

        my $mock_ua = LWP::UserAgent->new();
        $mock_ua->map(qr/.*/, sub {
            my ($request) = @_;
            my $response = HTTP::Response->new(
                '401',
                'Unauthorized',
                [ 'Content-type' => 'application/json' ],
                '{"type":"error.list","request_id":"0008pcfj9dh1eig57qv0","errors":[{"code":"token_unauthorized","message":"Unauthorized"}]}'
            );

            $response->request($request);

            return $response;
        });

        my $client = Intercom::Client->new({
            access_token => 'token',
            ua         => $mock_ua,
        });

        my $model = $call->($client);

        is($model->type, 'error.list', 'ErrorList model returned');
        cmp_deeply(
            $model->errors,
            [{
                code => 'token_unauthorized',
                message => 'Unauthorized'
            }],
            'Error returned correctly'
        );
    };
}

=head2 connection_failure (function $call) -> undef

Attempts to test the functionallity of $call when run on a client that
recieves a 502 response

Takes a function ref that will recieve a mocked Intercom::Client object
and should return the result of a resource call (i.e $mock_client->users->get())

    SharedTests::Request::connection_failure(sub {
        return shift->users->get({id => 1});
    });

=cut

sub connection_failure {
    my ($call) = @_;

    subtest 'connectkion failure' => sub {
        plan tests => 1;

        my $mock_ua = LWP::UserAgent->new();
        $mock_ua->map(qr/^.*$/ => sub {
            my ($request) = @_;
            my $response = HTTP::Response->new(502);

            $response->request($request);

            return $response;
        });

        my $client = Intercom::Client->new({
            access_token => 'token',
            ua         => $mock_ua,
        });

        my $error = $call->($client);

        is($error, undef, 'No error');
    };

}

1;
