package Intercom::Client::User;

use Moo;
use URI;

# Request handler for the client. This differes from the
# other SDK implementations to avoid circular references
has request_handler => (is => 'ro', required => 1);

=head1 NAME

Intercom::Client::User - User Resource class

=head1 SYNOPSIS

    my $user = $client->users->get({id => 1});

=head1 DESCRIPTION

=head1 METHODS

=head2 create (HashRef $user_data) -> Intercom::Model::User|Intercom::Model::ErrorList

    my $user = $client->users->create({
        email => 'test@test.com',
        companies => [{
            company_id => 366,
            name => 'test'
        }];
    });

Create a new user with the provided $user_data.

Will return a new instance of a Intercom::Model::User or an instance of an Intercom::Model::ErrorList

SEE ALSO:
    L<Create Users|https://developers.intercom.com/intercom-api-reference/reference#create-or-update-user>

=cut

sub create {
    my ($self, $user_data) = @_;

    return $self->request_handler->post(URI->new('/users'), $user_data);
}

sub update {
    my ($self) = @_;

    return $self->create(@_);
}

sub list {
    my ($self, $options) = @_;

    return $self->request_handler->get(URI->new('/users'), $options);
}

=head2 get (HashRef $params) -> Intercom::Model::User|Intercom::Model::ErrorList

    my $user = $client->users->get({id => 1});
    my $user2 = $client->users->get({email => 'test@test.com'});
    my $user3 = $client->users->get({user_id => '12333'});

Retrieve a user based on their primary intercom ID ($params->{id})

alternatively retrieve a user as identified by their email ($params->{email})
or custom user_id ($params->{user_id})

Returns either an instance of an Intercom::Model::User or an instance of an Intercom::Model::ErrorList

SEE ALSO: L<View a User|https://developers.intercom.com/intercom-api-reference/v1.1/reference#view-a-user>

=cut

sub get {
    my ($self, $params) = @_;

    return $self->request_handler->get($self->_user_path($params));
}

sub scroll {
    my ($self, $options) = @_;

    return $self->request_handler->get(URI->new('/users/scroll'), $options);
}

sub archive {
    my ($self, $params) = @_;

    return $self->request_handler->delete($self->_user_path($params));
}

sub permanently_delete {
    my ($self, $id, $options) = @_;

    return $self->request_handler->post(URI->new('/user_delete_requests'), $options);
}

sub _user_path {
    my ($self, $params) = @_;

    if (my $id = $params->{id}) {
        return URI->new("/users/$id");
    }

    my $uri = URI->new('/users');
    if (my $email = $params->{email}) {
        $uri->query_form(email => $email);
        return $uri
    }

    if (my $user_id = $params->{user_id}) {
        $uri->query_form(user_id => $user_id);
        return $uri;
    }

    confess('No [id], [email] or [user_id] provided to identify user');
}

1;
