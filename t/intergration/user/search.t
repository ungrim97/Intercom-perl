use lib 't/lib';

use JSON;
use Test::Most tests => 4;
use Test::MockObject;
use Test::Mock::LWP::Dispatch;
use SharedTests::Request;
use SharedTests::User;

use Intercom::Client;

SharedTests::Request::all_tests(sub {
    return shift->users->get(1);
});

subtest 'via Email' => sub {
    plan tests => 1;

    my $user_data = user_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/users\?email=test%40test.com$# => sub {
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

    my $resource = $client->users->search({email => 'test@test.com'});
    SharedTests::User::test_resource_generation($resource->users->[0], $user_data->{users}[0]);
};

subtest 'via user_id' => sub {
    plan tests => 1;

    my $user_data = user_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/users\?user_id=22$# => sub {
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
        ua          => $mock_ua
    });

    my $resource = $client->users->search({user_id => 22});
    SharedTests::User::test_resource_generation($resource->users->[0], $user_data->{users}[0]);
};

subtest 'Missing param' => sub {
    my $mock_ua = LWP::UserAgent->new();
    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $errors = $client->users->get();

    is($errors->errors->[0]{code}, 'parameter_not_found', 'Error returned');
};

sub user_data {
	return {
        type => 'user.list',
        users => [{
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
        }],
    };
}
