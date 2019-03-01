package Intercom::Client;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Moo;

use LWP::UserAgent;
use URI;

use Intercom::Client::RequestHandler;

use Intercom::Client::User;

# Configuration params passed to request handler
has auth_token => ( is => 'ro', required => 1 );
has base_url   => ( is => 'ro', default  => sub { return URI->new('https://api.intercom.io'); } );
has ua         => ( is  => 'ro', default  => sub { return LWP::UserAgent->new() } );

# Handler to pack and unpack all request/responses
has _request_handler => ( is => 'lazy' );
sub _build__request_handler {
    my ($self) = @_;

    return Intercom::Client::RequestHandler->new({
        base_url   => $self->base_url,
        auth_token => $self->auth_token,
        ua         => $self->ua
    });
}

has users => ( is => 'rwp', builder => 1, reader => 'users' );
sub _build_users {
    return Intercom::Client::User->new({
        request_handler => shift->_request_handler()
    });
}

1;
__END__

=encoding utf-8

=head1 NAME

Intercom::Client - Perl SDK for the Intercom REST API

=head1 SYNOPSIS

    my $client = Intercom::Client->new({token => $auth_token});

    my $user = $client->users->fetch({email => $email})

=head1 DESCRIPTION

Simple client library to interface with the Intercom REST API.

Current supports L<v1.1|https://developers.intercom.com/intercom-api-reference/v1.1/reference>

=head1 RESOURCES

=head2 users

    # Create a user
    my $response = $client->users->create({
        email => 'jayne@serenity.io',
        custom_attributes: {
            foo: 'bar'
        }
    });

    # Update a user
    my $response = $client->users->update({
        email: 'jayne@serenity.io',
        custom_attributes: {
            foo: 'bar'
        }
    });


Provides an object representation of the /users/ API resources

SEE ALSO:
    L<Intercom::Client::User>

=head1 CONTRIBUTING

Patches are both encouraged and welcome. All contributers are however asked to follow some simple
guidelines:

=over

=item B<Add Tests>

Tests ensure your change doesn't get broken in the future

=item B<Document Changes>

Documentation ensures people are aware of your change

=item B<Use feature branches>

Feature branches help keep your changes easily accessible

=item B<One branch per feature>

Independant branches ensure your change can be accepted independant of other changes

=item B<Atomic commits>

Meaningful atomic commits help people understand the history of your change. Try and avoid commits like 'Fix typo' or 'fix broken test' by squashing them with the original change they fix. Commits like 'Implement test for feature X' and 'Modify X to achive Y' are more helpful.

=back

=head1 CREDIT

Most of the code here is 'inspired' heavily by the L<Node|https://github.com/intercom/intercom-node>
and L<Ruby|https://github.com/intercom/intercom-ruby> SDK implementations. It attempts to maintain
as similar an interface as possible

=head1 LICENSE

Copyright (C) Mike Eve.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Mike Eve E<lt>ungrim97@gmail.comE<gt>

=cut

