package Intercom::Client::RequestHandler;

use Moo;

use Carp qw/confess/;
use JSON qw/encode_json decode_json/;
use LWP::UserAgent;
use Module::Runtime qw/use_module/;
use Try::Tiny;
use URI;
use URI::QueryParam;

=head1 NAME

Intercom::Client::RequestHandler - Request/Response packing and unpacking

=head1 SYNOPSIS

    my $request_handler->new(
        base_url   => URI->new('https://api.intercom.io');
        access_token => '5jg2123asdsadhk4447ds',
        ua         => LWP::UserAgent->new(),
    );

    my $resource = $request_handler->get(URI->new('/users'));

=head1 DESCRIPTION

Request and Response handler for all Intercom requests.

This managed building the correct L<HTTP::Request> object
and unpacking the L<HTTP::Response> objects into Intercom::Model::*
objects

=head1 ATTRIBUTES

=head2 base_url (URI)

Base URL to use for all requests

=head2 access_token (Str)

The string auth token provided by Intercom

SEE ALSO: L<Access Tokens|https://developers.intercom.com/building-apps/docs/authorization#section-access-tokens>

=head2 ua

User Agent to be used to make requests. Should provide a 'request' methods that accepts
a L<HTTP::Request> object and returns a L<HTTP::Response> object.

Returned response object must return the original request object via $response->request.

=cut

has base_url   => ( is => 'ro', required => 1 );
has access_token => ( is => 'ro', required => 1 );
has ua         => ( is => 'ro', required => 1 );


=head1 METHODS

=head2 get (URI $uri) -> Intercom::Model::*|Intercom::Model::ErrorList

Make GET requests to the provided URI. If $uri is relative then it
will be merged with the L<base_url|#base_url>

=cut

sub get {
    my ($self, $uri) = @_;

    return $self->_send_request('GET', $uri);
}

=head2 put (URI $uri, HashRef $body) -> Intercom::Model::*|Intercom::Model::ErrorList

Make PUT requests to the provided URI sending the $body data encoded
as JSON. If the $uri is relative then it will be merged with the L<base_url|#base_url>

=cut

sub put {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('PUT', $uri, $body);
}

=head2 post (URI $uri, Any $body) -> Intercom::Model::*|Intercom::Model::ErrorList

Make POST requests to the provided URI sending the $body data encoded
as JSON. If the $uri is relative then it will be merged with the L<base_url|#base_url>

=cut

sub post {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('POST', $uri, $body);
}

=head2 delete (URI $uri, Any $body) -> Intercom::Model::*|Intercom::Model::ErrorList

Make DELETE requests to the provided URI sending the $body data encoded
as JSON. If the $uri is relative then it will be merged with the L<base_url|#base_url>

=cut

sub delete {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('DELETE', $uri, $body);
}

# _send_request (Str $method, URI $uri, Any $body) -> Intercom::Model::*|Intercom::Model::ErrorList
#
# Builds the HTTP::Request object from the provided data via _build_request,
# makes the request, then unpacks the response via _handle_response()

sub _send_request {
    my ($self, $method, $uri, $body) = @_;

    my $request = $self->_build_request($method, $uri, $body);

    return $self->_handle_response(
        $self->ua->request($request)
    );
}

# _build_request (Str $method, URI $uri, $body) -> HTTP::Request
#
# Uses the base_url to ensure $uri is absolute
#
# Serialises any body data as JSON
#
# Constructs the HTTP::Request object along with any necessary
# headers

sub _build_request {
    my ($self, $method, $uri, $body) = @_;

    my $url = $self->base_url->clone();
    if ($uri) {
        if ($uri->scheme) {
            $url = $uri;
        } else {
            $url->path_query($uri);
        }
    }

    my $request = HTTP::Request->new(
        $method,
        $url,
        $self->_build_headers,
        $self->_serialise_body($body)
    );

    return $request;
}

# _deserialise_body (Str $json) -> Any
#
# Deserialises a JSON response body. Returns
# undef if the body is undef.
#
# Dies if the body is malformed

sub _deserialise_body {
    my ($self, $json_body) = @_;

    if ($json_body) {
        return decode_json($json_body);
    }

    return;
}

# _serialise_body (Any $body) -> Str
#
# Serialised the body data as a JSON string.
# Returns undef if the body data is undef.
#
# dies if unable to serialise to a valid
# JSON string

sub _serialise_body {
    my ($self, $body) = @_;

    if ($body) {
        return encode_json($body);
    }

    return;
}

# _build_headers () -> Array
#
# Returns an array of header Key/Value pairs:
#
# Content-type: application/json
# Accept: application/json
# Authrization: Bearer $self->access_token
# Intercom-Version: 1.1

sub _build_headers {
    my ($self) = @_;

    return [
        'Accept'           => 'application/json',
        'Content-type'     => 'application/json',
        'Authorization'    => 'Bearer '.$self->access_token,
        'Intercom-Version' => '1.1'
    ];
}

# _handler_response (HTTP::Response $response) -> Intercom::Model::*|Any
#
# Main entry to unpack the response into an instance of an Intercom::Model
# object

sub _handle_response {
    my ($self, $response) = @_;

    my $response_data = $self->_deserialise_body($response->content);

    return unless $response_data;

    return $self->_build_resources($response_data, $response->request->url);
}

# _build_resource (Any $resource_data, URI $request_url) -> Intercom::Model::*|Any
#
# Recursive function that attempts to construct nested Intercom::Model objects
# returns:
#
#   - undef if $resource_data is undefined
#   - $resource_data if $resource_data is a string
#   - An Array of the results of each element passed to _build_sub_resources if
#     $resource_data is an array
#   - if $resource_data contains a ->{type} then construct a Intercom::Model::*
#     object otherwise just return $resource_data

sub _build_resources {
    my ($self, $resource_data, $request_url) = @_;

    # Empty resource
    if (! defined $resource_data) {
        return;
    }

    # We just have a string value as our resource
    if (!ref $resource_data){
        return $resource_data;
    }

    # List of sub resources (user.list etc)
    if (ref $resource_data eq 'ARRAY') {
        return $self->_build_sub_resources($resource_data, $request_url);
    }

    # Main resource data
    if (ref $resource_data eq 'HASH') {
        return $self->_build_resource($resource_data, $request_url);
    }

    # If here we probably have a JSON::Boolean obj, just return it
    return $resource_data;
}

# _build_resource (HashRef $resource_data, URI $request_url) -> Intercom::Model::*
sub _build_resource {
    my ($self, $resource_data, $request_url) = @_;

    my $model_data = {};
    for my $attribute (keys %$resource_data) {
        # Scrollables are magic pagination objects
        if ($attribute eq 'scroll_param'){
            $model_data->{pages} = $self->_build_scrollable_paginator(
                $resource_data->{$attribute},
                $request_url
            );

            next;
        }

        # Pagination objects are special
        if ($attribute eq 'pages') {
            $model_data->{$attribute} = $self->_build_paginator(
                $resource_data->{$attribute}
            );
            next;
        }

        $model_data->{$attribute} = $self->_build_resources(
            $resource_data->{$attribute},
            $request_url
        );
    }

    # typed resource
    if (my $type = $resource_data->{type}) {
        my $model = $self->_type_to_model($type);
        return $model->new($model_data);
    }

    # Untyped data
    return $model_data;
}

sub _build_sub_resources {
    my ($self, $sub_resources, $request_url) = @_;

    my $resources = [];
    for my $sub_resource (@{$sub_resources}) {
        push @{$resources}, $self->_build_resources(
            $sub_resource,
            $request_url
        );
    }

    return $resources;
}

sub _build_paginator {
    my ($self, $page_data) = @_;

    my $class_data = $page_data;
    $class_data->{request_handler} = $self;

    for my $attribute (qw/next last prev first/) {
        if ($class_data->{$attribute}) {
            $class_data->{$attribute} = URI->new($class_data->{$attribute});
        }
    }

    my $paginator_class = $self->_type_to_model('page');
    return $paginator_class->new($class_data);
}

sub _build_scrollable_paginator {
    my ($self, $scroll_param, $request_url) = @_;

    my $next_url = $request_url->clone;
    $next_url->query_param_append(scroll_param => $scroll_param);

    return $self->_build_paginator({ next => $next_url });
}

{
    my $type_map = {
        'error.list'          => 'ErrorList',
        'admin'               => 'Admin',
        'user'                => 'User',
        'user.list'           => 'UserList',
        'avatar'              => 'Avatar',
        'location_data'       => 'LocationData',
        'social_profile'      => 'SocialProfile',
        'social_profile.list' => 'SocialProfileList',
        'company'             => 'Company',
        'company.list'        => 'CompanyList',
        'segment'             => 'Segment',
        'segment.list'        => 'SegmentList',
        'tag.list'            => 'TagList',
        'tag'                 => 'Tag',
        'page'                => 'Page',
    };

    sub _type_to_model {
        my ($self, $type) = @_;

        return try {
            return use_module('Intercom::Model::'.$type_map->{$type});
        } catch {
            confess "Unable to find model for [$type]"
        };
    }
}

1;
