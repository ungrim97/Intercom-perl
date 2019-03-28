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

=head3 update (HasRef $company_data) -> Intercom::Resource::Company|Intercom::Resource::ErrorList

    my $company = $client->companies->update({
        company_id => 366,
        name       => 'test comp'
    });

Update an existing company with the provided $company_data. Company will be
matched by the 'company_id' fields in the data

Will return a new instance of a Intercom::Resource::Company or an instance of
an Intercom::Resource::ErrorList

SEE ALSO: L<Update Companys|https://developers.intercom.com/intercom-api-reference/reference#create-or-update-company>

=cut

sub update {
    my ($self, $company_data) = @_;

    unless ($company_data->{company_id}) {
        return Intercom::Resource::ErrorList->new(errors => [{
            code    => 'parameter_not_found',
            message => 'Update requires `company_id`'
        }]);
    }

    return $self->create($company_data);
}

=head3 get (Str $id) -> Intercom::Resource::Company|Intercom::Resource::ErrorList

    my $company = $client->companies->get(1);

Retrieve a company based on their primary intercom ID ($id)

Returns either an instance of an Intercom::Resource::Company or an instance of
an Intercom::Resource::ErrorList

SEE ALSO: L<View a Company|https://developers.intercom.com/intercom-api-reference/v1.1/reference#view-a-company>

=cut

sub get {
    my ($self, $id) = @_;

    unless ($id) {
        return Intercom::Resource::ErrorList->new(errors => [{
            code    => 'parameter_not_found',
            message => 'Get requires an `id` parameter'
        }]);
    }

    return $self->request_handler->get($self->_company_path({id => $id}));
}

=head3 find (HashRef $params) -> Intercom::Resource::Company|Intercom::Resource::ErrorList

    my $company = $client->companies->find({company_id => 1234});

Retrieve a company based on their company_id ($params->{company_id}), or the
name ($params->{name})

Returns either an instance of an Intercom::Resource::Company or an instance of
an Intercom::Resource::ErrorList

SEE ALSO: L<View a Company|https://developers.intercom.com/intercom-api-reference/v1.1/reference#view-a-company>

=cut

sub find {
    my ($self, $params) = @_;

    unless ($params->{company_id} || $params->{name}) {
        return Intercom::Resource::ErrorList->new(errors => [{
            code    => 'parameter_not_found',
            message => 'Find requires one of `company_id`, or `name`'
        }]);
    }

    if ($params->{company_id} && $params->{name}) {
        return Intercom::Resource::ErrorList->new(errors => [{
            code    => 'parameter_invalid',
            message => 'Find requires one of `company_id`, or `name`'
        }]);
    }
    return $self->request_handler->get($self->_company_path($params));
}

=head3 list (Hashref $options) -> Intercom::Resource::CompanyList|Intercom::Resource::ErrorList

    my $companies = $client->companies->list({page => 3}) # 3rd page of companies

    do {
        confess 'Error' if $companies->type eq 'ErrorList';

        for my $company ($companies->companies){
            ...
        }
    } while ($companies = $companies->page->next())

Retrieve a list of companies. by default this will fetch the last 50 created
companies. The returned L<Intercom::Resource::CompanyList> object also contains
a L<page object|Intercom::Resource::Page> which can be used to fetch more
companies in a paginated fashion

Available options are:

=over

=item *

page - numeric page to retrieve

=item *

per_page - number of companies to include per page (default 50, max 60)

=item *

order - Direction to sort the companies via the sort value (default desc)

=back

SEE ALSO: L<List Companiess|https://developers.intercom.com/intercom-api-reference/v1.1/reference#list-companies>

=cut

sub list {
    my ($self, $options) = @_;

    my $uri = URI->new('/companies');
    $uri->query_form($options);

    return $self->request_handler->get($uri);
}

=head3 search (HashRef $params) -> Intercom::Resource::CompanyList|Intercom::Resource::ErrorList

    my $companies3 = $client->companies->search({tag_id => '12333'});
    my $companies4 = $client->companies->search({segment_id => '12333'});

Search for companies as identified by a tag_id ($params->{tag_id}), or a
segment_id ($params->{segment_id})

Returns either an instance of an Intercom::Resource::CompanyList or an instance
of an Intercom::Resource::ErrorList

SEE ALSO: L<Search by Tag|https://developers.intercom.com/intercom-api-reference/v1.1/reference#list-by-tag-or-segment>

=cut

sub search {
    my ($self, $params) = @_;

    unless ( $params->{tag_id} || $params->{segment_id} ) {
        return Intercom::Resource::ErrorList->new(errors => [{
            code => 'parameter_not_found',
            message => 'Search requires one of `tag_id`, or `segment_id`'
        }]);
    }

    if ( $params->{tag_id} && $params->{segment_id} ) {
        return Intercom::Resource::ErrorList->new(errors => [{
            code => 'parameter_invalid',
            message => 'Search requires one of `tag_id`, or `segment_id`'
        }]);
    }

    return $self->request_handler->get($self->_company_path($params));
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

    if (my $segment_id = $params->{segment_id}) {
        $uri->query_form(segment_id => $segment_id);
        return $uri
    }

    confess('No [id], [name], [company_id], [tag_id], or [segment_id] provided to identify company');
}

1;
