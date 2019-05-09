package Intercom::Client;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.03";

use Moo;

use LWP::UserAgent;
use URI;

use Intercom::Client::RequestHandler;
use Intercom::Client::User;
use Intercom::Client::Company;

=head1 NAME

Intercom::Client - Perl SDK for the Intercom REST API

=head1 SYNOPSIS

    use Intercom::Client;

    my $client = Intercom::Client->new({token => $access_token});

    my $user = $client->users->search({email => $email});

=head1 DESCRIPTION

B<BETA>

Simple client library to interface with the Intercom REST API.

Current supports L<v1.1|https://developers.intercom.com/intercom-api-reference/v1.1/reference>
of the API.

B<THIS SOFTWARE IS CURRENTLY IN BETA AND ONLY SUPPORTS THE USER RESOURCE>

=head2 ATTRIBUTES

=head3 base_url (URI)

default - 'https://api.intercom.io'

Base URL to use for all requests

=head3 access_token (Str)

B<required>

The string auth token provided by Intercom

SEE ALSO: L<Access Tokens|https://developers.intercom.com/building-apps/docs/authorization#section-access-tokens>

=head3 ua

default - LWP::UserAgent->new()

User Agent to be used to make requests. Should provide a 'request' methods that accepts
a L<HTTP::Request> object and returns a L<HTTP::Response> object.

Returned response object must return the original request object via $response->request.

=cut

# Configuration params passed to request handler
has access_token => ( is => 'ro', required => 1 );
has base_url     => ( is => 'ro', default  => sub { return URI->new('https://api.intercom.io'); } );
has ua           => ( is => 'ro', default  => sub { return LWP::UserAgent->new() } );

# Handler to pack and unpack all request/responses
has _request_handler => ( is => 'lazy' );
sub _build__request_handler {
    my ($self) = @_;

    return Intercom::Client::RequestHandler->new({
        base_url     => $self->base_url,
        access_token => $self->access_token,
        ua           => $self->ua
    });
}

=head2 RESOURCES

=head3 users

    # Create a user
    my $response = $client->users->create({
        email             => 'jayne@serenity.io',
        custom_attributes => {
            foo => 'bar'
        }
    });

    # Update a user
    my $response = $client->users->update({
        email             => 'jayne@serenity.io',
        custom_attributes => {
            foo => 'bar'
        }
    });


Provides an object representation of the /users/ API resources

SEE ALSO:
    L<Intercom::Client::User>

=cut

has _users => ( is => 'lazy', reader => 'users' );
sub _build__users {
    return Intercom::Client::User->new({
        request_handler => shift->_request_handler()
    });
}

=head3 companies

    # Create Company
    my $response = $client->companies->create({
        name       => 'Test Company',
        company_id => '12345',
    });

    # Update a Company
    my $response = $client->companies->update({
        name       => 'Company',
        company_id => '12345'
    });

Provides an object representation of the /companies/ API resource

SEE ALSO:
    L<Intercom::Client::Company>

=cut

has _companies => ( is => 'lazy', reader => 'companies' );
sub _build__companies {
    return Intercom::Client::Company->new({
        request_handler => shift->_request_handler()
    });
}

1;

=head1 INSTALLATION

    cpanm Intercom::Client;

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

Thanks also to Broadbean Technology for the time to create this

=head1 LICENSE

Copyright (C) Mike Eve.

Copyright (C) Broadbean Technology

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Mike Eve E<lt>ungrim97@gmail.comE<gt>

=cut

