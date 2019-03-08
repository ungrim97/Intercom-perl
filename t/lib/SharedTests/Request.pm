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

=head3 all_tests (function $call) -> undef

    SharedTests::Request::all(sub {
        return shift->users->get({id => 1});
    });

Run all of the SharedTests::Request tests using the same
call

=cut

sub all_tests {
    my ($call) = @_;

    subtest 'All SharedTests::Request' => sub {
        auth_failure($call);
        headers($call);
        connection_failure($call);
    };
}

=head3 auth_failure (function $call) -> undef

    SharedTests::Request::auth_failure(sub {
        return shift->users->get({id => 1});
    });

Attempts to test the functionallity of $call when run on a client that
has an invalid auth token

Takes a function ref that will recieve a mocked Intercom::Client object
and should return the result of a resource call (i.e $mock_client->users->get())


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

        my $resource = $call->($client);

        is($resource->type, 'error.list', 'ErrorList resource returned');
        cmp_deeply(
            $resource->errors,
            [{
                code => 'token_unauthorized',
                message => 'Unauthorized'
            }],
            'Error returned correctly'
        );
    };
}

=head3 headers (function $call) -> undef

    SharedTests::Request::headers(sub {
        return shift->users->get({id => 1})
    })

Tests that the functionality of $call would generate the correct headers
for the request

Takes a function ref that will recieve a mocked Intercom::Client object
and should return the result of a resource call (i.e $mock_client->users->get())

=cut

sub headers {
    my ($call) = @_;

    subtest 'headers' => sub {
        my $mock_ua = LWP::UserAgent->new();
        my $expected_headers = {
            'Authorization'    => 'Bearer token',
            'Content-Type'     => 'application/json',
            'Accept'           => 'application/json',
            'Intercom-Version' => '1.1',
            'User-Agent'       => $mock_ua->agent
        };

        $mock_ua->map(
            sub {
                my ($request) = @_;

                cmp_deeply({$request->headers->flatten}, $expected_headers, 'Headers generated as anticipated');

                return 1;
            },
            sub {
                my ($request) = @_;

                my $response = HTTP::Response->new(
                    '401',
                    'Unauthorized',
                    [ 'Content-type' => 'application/json' ],
                    '{"type":"error.list","request_id":"0008pcfj9dh1eig57qv0","errors":[{"code":"token_unauthorized","message":"Unauthorized"}]}'
                );
                $response->request($request);
                return $response;
            }
        );

        my $client = Intercom::Client->new({
            access_token => 'token',
            ua           => $mock_ua,
        });

        $call->($client);
    };
}

=head3 connection_failure (function $call) -> undef

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

    subtest 'connection failure' => sub {
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

=head3 unrecognised_type (Function $code) -> undef

    SharedTests::Request::unrecognised_type(sub {
        return shift->users->get({id => 1});
    });

Attempts to test the functionallity of $call when it recieves
a resource of an unknown type

Takes a function ref that will recieve a mocked Intercom::Client object
and should throw an error

=cut

sub unrecognised_type {
    my ($call) = @_;

    subtest 'unrecognised_type' => sub {
        plan tests => 1;

        my $mock_ua = LWP::UserAgent->new();
        $mock_ua->map(qr/^.*$/ => sub {
            my ($request) = @_;

            my $response = HTTP::Response->new(
                200,
                'OK',
                [ 'Content-type' => 'application/json' ],
                '{"type": "unkown_type", "data": "random_data"}'
            );

            $response->request($request);

            return $response;
        });

        my $client = Intercom::Client->new({
            access_token => 'token',
            ua         => $mock_ua,
        });

        throws_ok(
            sub { $call->($client); },
            qr/Unable to find resource for \[unknown_type\]/,
            'Threw error for unknown type'
        );
    };

}

1;
