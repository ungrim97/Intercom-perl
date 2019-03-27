package Intercom::Client::Company;

use Moo;
use Carp;
use URI;
use URI::QueryParam;
use Intercom::Resource::ErrorList;

# Request handler for the client. This differes from the
# other SDK implementations to avoid circular references
has request_handler => (is => 'ro', required => 1);

=head1 NAME

Intercom::Client::Company - Company Resource class

=head1 SYNOPSIS

    my $companies = $client->companies->search({email => 'test1@test.com});
    my $company = $companies->companies->[0];

    $company = $client->companies->update({
        company_id => '1234',
        name       => 'test comp'
    });

=head1 DESCRIPTION

Core client lib for access to the /company resource in the API

SEE ALSO: L<Companys|https://developers.intercom.com/intercom-api-reference/reference#companies>

=head2 METHODS

=head3 create (HashRef $company_data) -> Intercom::Resource::Company|Intercom::Resource::ErrorList

    my $company = $client->companies->create({
        company_id => 366,
        name       => 'test comp'
    });

Create a new company with the provided $company_data.

Will return a new instance of a Intercom::Resource::Company or an instance of
an Intercom::Resource::ErrorList

SEE ALSO: L<Create Companys|https://developers.intercom.com/intercom-api-reference/reference#create-or-update-company>

=cut

sub create {
    my ($self, $company_data) = @_;

    return $self->request_handler->post(URI->new('/companies'), $company_data);
}

=cut

sub _company_path {
    my ($self, $params) = @_;

    if (my $id = $params->{id}) {
        return URI->new("/companies/$id");
    }

    my $uri = URI->new('/companies');
    if (my $name = $params->{name}) {
        $uri->query_form(name => $name);
        return $uri
    }

    if (my $company_id = $params->{company_id}) {
        $uri->query_form(company_id => $company_id);
        return $uri;
    }

    if (my $tag_id = $params->{tag_id}) {
        $uri->query_form(tag_id => $tag_id);
        return $uri
    }
    elsif (my $segment_id = $params->{segment_id}) {
        $uri->query_form(segment_id => $segment_id);
        return $uri
    }

    confess('No [id], [name], [company_id], [tag_id], or [segment_id] provided to identify company');
}

1;
