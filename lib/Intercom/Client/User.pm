package Intercom::Client::User;

use Moo;

# Request handler for the client. This differes from the
# other SDK implementations to avoid circular references
has request_handler => (is => 'ro', required => 1);

sub create {
    my ($self, $options) = @_;

    return $self->request_handler->post('users', $options);
}

sub update {
    my ($self) = @_;

    return $self->create(@_);
}

sub get {
    my ($self, $id, $options) = @_;

    return $self->request_handler->get($self->_user_path($id), $options);
}

sub scroll {
    my ($self, $options) = @_;

    return $self->request_handler->get('users/scroll', $options);
}

sub archive {
    my ($self, $id, $options) = @_;

    return $self->request_handler->delete($self->_user_path($id), $options);
}

sub permanently_delete {
    my ($self, $id, $options) = @_;

    return $self->request_handler->post('user_delete_requests', $options);
}

sub _user_path {
    return 'users/'.shift;
}

1;
