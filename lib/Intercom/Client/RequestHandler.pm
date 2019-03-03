package Intercom::Client::RequestHandler;

use Moo;

use Carp qw/confess/;
use JSON qw/encode_json decode_json/;
use LWP::UserAgent;
use Module::Runtime qw/use_module/;
use Try::Tiny;
use URI;

has base_url   => ( is => 'ro', required => 1 );
has auth_token => ( is => 'ro', required => 1 );
has ua         => ( is => 'ro', required => 1 );

sub get {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('GET', $uri, $body);
}

sub put {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('PUT', $uri, $body);
}

sub post {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('POST', $uri, $body);
}

sub delete {
    my ($self, $uri, $body) = @_;

    return $self->_send_request('DELETE', $uri, $body);
}

sub _send_request {
    my ($self, $method, $uri, $body) = @_;

    my $request = $self->_build_request($method, $uri, $body);

    return $self->_handle_response(
        $self->ua->request($request)
    );
}

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

sub _deserialise_body {
    my ($self, $json_body) = @_;

    if ($json_body) {
        return decode_json($json_body);
    }

    return;
}

sub _serialise_body {
    my ($self, $body) = @_;

    if ($body) {
        return encode_json($body);
    }

    return;
}

sub _build_headers {
    my ($self) = @_;

    return [
        'Accept'        => 'application/json',
        'Content-type'  => 'application/json',
        'Authorization' => 'Bearer '.$self->auth_token,
    ];
}

sub _handle_response {
    my ($self, $response) = @_;

    my $response_data = $self->_deserialise_body($response->content);

    return unless $response_data;

    return $self->_build_resources($response_data);
}

# Run over the data and construct any sub models that were returned in the primary
# response
sub _build_resources {
    my ($self, $resource_data) = @_;

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
        my $resources = [];
        for my $sub_resource_data (@{$resource_data}) {
            push @{$resources}, $self->_build_resources($sub_resource_data);
        }

        return $resources;
    }

    if (ref $resource_data eq 'HASH') {
        # Main resource data
        my $model_data = {};
        for my $attribute (keys %$resource_data) {
            # Pagination objects are special
            if ($attribute eq 'pages') {
                $self->_build_paginator($resource_data->{$attribute});
            } else {
                $model_data->{$attribute} = $self->_build_resources($resource_data->{$attribute});
            }
        }

        # typed resource
        if ($resource_data->{type}) {
            my $model = $self->_type_to_model($resource_data->{type});
            return $model->new($model_data);
        }

        # Untyped data
        return $model_data;
    }

    # If here we probably have a JSON::Boolean obj, just return it
    return $resource_data;
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

{
    my $type_map = {
        'error.list'          => 'ErrorList',
        'admin'               => 'Admin',
        'user'                => 'User',
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
