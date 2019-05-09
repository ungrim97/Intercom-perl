# NAME

Intercom::Client - Perl SDK for the Intercom REST API

# SYNOPSIS

    use Intercom::Client;

    my $client = Intercom::Client->new({token => $access_token});

    my $user = $client->users->search({email => $email});

# DESCRIPTION

**BETA**

Simple client library to interface with the Intercom REST API.

Current supports [v1.1](https://developers.intercom.com/intercom-api-reference/v1.1/reference)
of the API.

**THIS SOFTWARE IS CURRENTLY IN BETA AND ONLY SUPPORTS THE USER RESOURCE**

## ATTRIBUTES

### base\_url (URI)

default - 'https://api.intercom.io'

Base URL to use for all requests

### access\_token (Str)

**required**

The string auth token provided by Intercom

SEE ALSO: [Access Tokens](https://developers.intercom.com/building-apps/docs/authorization#section-access-tokens)

### ua

default - LWP::UserAgent->new()

User Agent to be used to make requests. Should provide a 'request' methods that accepts
a [HTTP::Request](https://metacpan.org/pod/HTTP::Request) object and returns a [HTTP::Response](https://metacpan.org/pod/HTTP::Response) object.

Returned response object must return the original request object via $response->request.

## RESOURCES

### users

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
    [Intercom::Client::User](https://metacpan.org/pod/Intercom::Client::User)

### companies

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
    [Intercom::Client::Company](https://metacpan.org/pod/Intercom::Client::Company)

# INSTALLATION

    cpanm Intercom::Client;

# CONTRIBUTING

Patches are both encouraged and welcome. All contributers are however asked to follow some simple
guidelines:

- **Add Tests**

    Tests ensure your change doesn't get broken in the future

- **Document Changes**

    Documentation ensures people are aware of your change

- **Use feature branches**

    Feature branches help keep your changes easily accessible

- **One branch per feature**

    Independant branches ensure your change can be accepted independant of other changes

- **Atomic commits**

    Meaningful atomic commits help people understand the history of your change. Try and avoid commits like 'Fix typo' or 'fix broken test' by squashing them with the original change they fix. Commits like 'Implement test for feature X' and 'Modify X to achive Y' are more helpful.

# CREDIT

Most of the code here is 'inspired' heavily by the [Node](https://github.com/intercom/intercom-node)
and [Ruby](https://github.com/intercom/intercom-ruby) SDK implementations. It attempts to maintain
as similar an interface as possible

Thanks also to Broadbean Technology for the time to create this

# LICENSE

Copyright (C) Mike Eve.

Copyright (C) Broadbean Technology

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Mike Eve <ungrim97@gmail.com>
