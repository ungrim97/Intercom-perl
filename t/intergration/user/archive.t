use lib 't/lib';

use JSON;
use Test::Most tests => 5;
use Test::MockObject;
use Test::Mock::LWP::Dispatch;
use SharedTests::Request;

use Intercom::Client;

SharedTests::Request::auth_failure(sub {
    return shift->users->archive({email => 'test@test.com'});
});

SharedTests::Request::connection_failure(sub {
    return shift->users->archive({email => 'test@test.com'});
});

subtest 'via ID' => sub {
    plan tests => 28;

    my $user_data = user_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/users/1$# => sub {
        my ($request) = @_;
        my $response = HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($user_data)
        );

        $response->request($request);
        return $response;
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua         => $mock_ua
    });

    my $resource = $client->users->archive({id => 1});
    test_resource_generation($resource, $user_data);
};

subtest 'via Email' => sub {
    plan tests => 28;

    my $user_data = user_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/users\?email=test%40test\.com$# => sub {
        my ($request) = @_;
        my $response = HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($user_data)
        );

        $response->request($request);
        return $response;
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua         => $mock_ua
    });

    test_resource_generation($client->users->archive({email => 'test@test.com'}), $user_data);
};

subtest 'via UserID' => sub {
    plan tests => 28;

    my $user_data = user_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/users\?user_id=23134# => sub {
        my ($request) = @_;
        my $response = HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($user_data)
        );

        $response->request($request);
        return $response;
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua         => $mock_ua
    });

    test_resource_generation($client->users->archive({user_id => 23134}), $user_data);
};

sub test_resource_generation {
    my ($resource, $user_data) = @_;

    is($resource->type, 'user', 'User resource returned');

    # Basic user resource data
    is($resource->id, $user_data->{'id'}, 'id has correct value');
    is($resource->user_id, $user_data->{'user_id'}, 'user_id has correct value');
    is($resource->email, $user_data->{'email'}, 'email has correct value');
    is($resource->phone, $user_data->{'phone'}, 'phone has correct value');
    is($resource->name, $user_data->{'name'}, 'name has correct value');
    is($resource->updated_at, $user_data->{'updated_at'}, 'updated_at has correct value');
    is($resource->last_seen_ip, $user_data->{'last_seen_ip'}, 'last_seen_ip has correct value');
    is($resource->unsubscribed_from_emails, $user_data->{'unsubscribed_from_emails'}, 'unsubscribed_from_emails has correct value');
    is($resource->last_request_at, $user_data->{'last_request_at'}, 'last_request_at has correct value');
    is($resource->signed_up_at, $user_data->{'signed_up_at'}, 'signed_up_at has correct value');
    is($resource->created_at, $user_data->{'created_at'}, 'created_at has correct value');
    is($resource->session_count, $user_data->{'session_count'}, 'session_count has correct value');
    is($resource->user_agent_data, $user_data->{'user_agent_data'}, 'user_agent_data has correct value');
    is($resource->pseudonym, $user_data->{'pseudonym'}, 'pseudonym has correct value');
    is($resource->anonymous, $user_data->{'anonymous'}, 'anonymous has correct value');
    is($resource->referrer, $user_data->{'referrer'}, 'referrer has correct value');
    is($resource->utm_campaign, $user_data->{'utm_campaign'}, 'utm_campaign has correct value');
    is($resource->utm_content, $user_data->{'utm_content'}, 'utm_content has correct value');
    is($resource->utm_medium, $user_data->{'utm_medium'}, 'utm_medium has correct value');
    is($resource->utm_source, $user_data->{'utm_source'}, 'utm_source has correct value');
    is($resource->utm_term, $user_data->{'utm_term'}, 'utm_term has correct value');

    # User custom attributes
    cmp_deeply($resource->custom_attributes, $user_data->{custom_attributes}, 'custom_attributes has the correct value');

    # Avatar
    is($resource->avatar->type, 'avatar', 'User has Avatar resource');
    is($resource->avatar->image_url, $user_data->{avatar}{'image_url'}, 'Avatar->image_url has correct value');

    # Companies
    is($resource->companies->type, 'company.list', 'User has companies list resource');
    is($resource->companies->companies->[0]->type, 'company', 'CompanyList has a company resource');
    is($resource->companies->companies->[0]->id, $user_data->{companies}{companies}[0]{'id'}, 'Company->id has correct value');
};


sub user_data {
	return {
        type                     => "user",
        id                       => '530370b477ad7120001d',
        user_id                  => '25',
        email                    => 'wash@serenity.io',
        phone                    => '+1123456789',
        name                     => 'Hoban Washburne',
        updated_at               => 1392734388,
        last_seen_ip             => '1.2.3.4',
        unsubscribed_from_emails => JSON::false,
        last_request_at          => 1397574667,
        signed_up_at             => 1392731331,
        created_at               => 1392734388,
        session_count            => 179,
        user_agent_data          => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9',
        pseudonym                => undef,
        anonymous                => JSON::false,
        referrer                 => 'https://example.org',
        utm_campaign             => undef,
        utm_content              => undef,
        utm_medium               => undef,
        utm_source               => undef,
        utm_term                 => undef,
        custom_attributes        => {
            paid_subscriber        => JSON::true,
            monthly_spend          => 155.5,
            team_mates             => 1
        },
        avatar => {
            type      => 'avatar',
            image_url => 'https://example.org/128Wash.jpg'
        },
        location_data => {
            type           => 'location_data',
            city_name      => 'Dublin',
            continent_code => 'EU',
            country_code   => 'IRL',
            country_name   => 'Ireland',
            latitude       => 53.159233,
            longitude      => -6.723,
            postal_code    => undef,
            region_name    => 'Dublin',
            timezone       => 'Europe/Dublin'
        },
        social_profiles   => {
            type            => 'social_profile.list',
            social_profiles => [{
                    type        => 'social_profile',
                    name        => 'twitter',
                    id           => '1235d3213',
                    username    => 'th1sland',
                    url         => 'http://twitter.com/th1sland'
                }]
        },
        companies   => {
            type      => 'company.list',
            companies => [{
                    type => 'company',
                    id  => '530370b477ad7120001e'
                }]
        },
        segments => {
            type     => 'segment.list',
            segments => [{
                    type => 'segment',
                    id => '5310d8e7598c9a0b24000002'
                }]
        },
        tags => {
            type => 'tag.list',
            tags => [{
                    type => 'tag',
                    id => '202'
                }]
        }
    };
}
