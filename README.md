[![Build Status](https://travis-ci.com/ungrim97/intercom-perl.svg?branch=master)](https://travis-ci.com/ungrim97/intercom-perl)
# NAME

Intercom::Client - Perl SDK for the Intercom REST API

# SYNOPSIS

    my $client = Intercom::Client->new({token => $auth_token});

    my $user = $client->users->fetch({email => $email})

# DESCRIPTION

Simple client library to interface with the Intercom REST API.

Current supports [v1.1](https://developers.intercom.com/intercom-api-reference/v1.1/reference)

# RESOURCES

## users

    # Create a user
    my $response = $client->users->create({
        email => 'jayne@serenity.io',
        custom_attributes: {
            foo: 'bar'
        }
    });

    # Update a user
    my $response = $client->users->update({
        email: 'jayne@serenity.io',
        custom_attributes: {
            foo: 'bar'
        }
    });

Provides an object representation of the /users/ API resources

SEE ALSO:
    [Intercom::Client::User](https://metacpan.org/pod/Intercom::Client::User)

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

# LICENSE

Copyright (C) Mike Eve.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Mike Eve <ungrim97@gmail.com>
