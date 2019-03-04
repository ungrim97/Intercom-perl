package Intercom::Client::User;

use Moo;
use URI;
use Intercom::Model::ErrorList;

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

=head2 update (HasRef $user_data) -> Intercom::Model::User|Intercom::Model::ErrorList

    my $user = $client->users->update({
        email => 'test@test.com',
        companies => [{
            company_id => 366,
            name => 'test'
        }];
    });

Update an existing user with the provided $user_data. User will be matched by the value of the 'id', 'email'
or 'user_id' fields in the data

Will return a new instance of a Intercom::Model::User or an instance of an Intercom::Model::ErrorList

SEE ALSO:
    L<Update Users|https://developers.intercom.com/intercom-api-reference/reference#create-or-update-user>


=cut

sub update {
    my ($self, $user_data) = @_;

    unless ($user_data->{id} || $user_data->{email} || $user_data->{user_id}) {
        return Intercom::Model::ErrorList->new(errors => [{
            code => 'parameter_not_found',
            message => 'Update requires one of `id`, `email` or `user_id`'
        }]);
    }

    return $self->create($user_data);
}

=head2 list (Hashref $options) -> Intercom::Model::UserList|Intercom::Model::ErrorList

    my $users = $client->users->list({created_since => 365}) # all users in the last year

    do {
        confess 'Error' if $users->type eq 'ErrorList';

        for my $user ($users->users){
            ...
        }
    } while ($users = $users->page->next() )

Retrieve a list of users. by default this will fetch the last 50 created users. The returned
L<Intercom::Model::UserList> object also contains a L<page object|Intercom::Model::Page> which
can be used to fetch more users in a paginated fashion

Available options are:

=over

=item *

page - numeric page to retrieve

=item *

per_page - number of users to include per page (default 50, max 60)

=item *

order - Direction to sort the users via the sort value (default desc)

=item *

sort - Field to sort on. Either created_at, last_request_at, signed_up_at or updated_at. (default created_at)

=item *

created_since - limit results to users that were created in that last number of days

=back

SEE ALSO: L<List Users|https://developers.intercom.com/intercom-api-reference/v1.1/reference#list-users>

=cut

sub list {
    my ($self, $options) = @_;

    my $uri = URI->new('/users');
    $uri->query_form($options);

    return $self->request_handler->get($uri);
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

=head2 scroll () -> Intercom::Model::UserList|Intercom::Model::ErrorList

    my $users = $client->users->list({created_since => 365}) # all users in the last year

    do {
        confess 'Error' if $users->type eq 'ErrorList';

        for my $user ($users->users){
            ...
        }
    } while ($users = $users->page->next() )

Efficiently retrieve a list of users. by default this will fetch the last 50 created users. The returned
L<Intercom::Model::UserList> object also contains a L<page object|Intercom::Model::Page> which
can be used to fetch more users in a paginated fashion

NOTE: Scrolled user lists can only be paged to the next page. There is no ability to return
to a previous page

SEE ALSO: L<Scroll users|https://developers.intercom.com/intercom-api-reference/v1.1/reference#iterating-over-all-users>

=cut

sub scroll {
    my ($self) = @_;

    return $self->request_handler->get(URI->new('/users/scroll'));
}

=head2 archive (HashRef $params) -> Intercom::Model::User|Intercom::Model::ErrorList

    my $user = $client->users->get({id => 1});
    my $user2 = $client->users->get({email => 'test@test.com'});
    my $user3 = $client->users->get({user_id => '12333'});

Archive a user based on their primary intercom ID ($params->{id})

alternatively archive a user as identified by their email ($params->{email})
or custom user_id ($params->{user_id})

Returns either an instance of an Intercom::Model::User or an instance of an Intercom::Model::ErrorList

SEE ALSO: L<Archive a User|https://developers.intercom.com/intercom-api-reference/v1.1/reference#archive-a-user>

=cut

sub archive {
    my ($self, $params) = @_;

    return $self->request_handler->delete($self->_user_path($params));
}

=head1 permanently_delete (Str $id) -> HashRef|Intercom::Model::ErrorList

    my $return = $client->users->permanently_delete(1);

Permanently remove a user as identified by thier Intercom user id ($id).

Returns either a hashref containing a single id key whose value is the
id of the deleted user.

SEE ALSO: L<Delete a user|https://developers.intercom.com/intercom-api-reference/v1.1/reference#delete-users>

=cut

sub permanently_delete {
    my ($self, $id) = @_;

    return $self->request_handler->post(
        URI->new('/user_delete_requests'),
        {intercom_user_id => $id}
    );
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
