package Intercom::Resource::Page;

use Moo;

has next        => ( is => 'ro', predicate => 1 );
has last        => ( is => 'ro', predicate => 1 );
has prev        => ( is => 'ro', predicate => 1 );
has first       => ( is => 'ro', predicate => 1 );
has page        => ( is => 'ro' );
has per_page    => ( is => 'ro' );
has total_pages => ( is => 'ro' );

has request_handler => ( is => 'ro', required => 1 );

sub get_next {
    my ($self) = @_;

    return unless $self->has_next;

    return $self->request_handler->get($self->next);
}

sub get_previous_page {
    my ($self) = @_;

    return unless $self->has_prev;

    return $self->request_handler->get($self->prev);
}

sub get_first_page {
    my ($self) = @_;

    return unless $self->has_first;

    return $self->request_handler->get($self->first);
}

sub get_last_page {
    my ($self) = @_;

    return unless $self->has_last;

    return $self->request_handler->get($self->last);
}

sub type { return 'page'; }

1;
