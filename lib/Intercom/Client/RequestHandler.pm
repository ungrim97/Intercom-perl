package Intercom::Client::RequestHandler;

use Moo;

use JSON qw/encode_json decode_json/;
use Log::Any qw/$log/;
use LWP::UserAgent;
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

sub _handle_response {
    my ($self, $response) = @_;

    my $response_data = $self->_deserialise_body($response->content);
    if ($response->is_success) {
        $log->tracef(
            "[%s] - %s",
            $response->status_line,
            $response->decoded_content
        );
        return ($response_data);
    }

    $log->tracef(
        "[%s] - %s",
        $response->status_line,
        $response->decoded_content
    );
    return (undef, $response_data // '');
}

sub _build_request {
    my ($self, $method, $uri, $body) = @_;

    my $url = $self->base_url->clone();
    $url->path($uri);

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

    $log->infof("Deserialising json: [%s]", $json_body);
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

1;
