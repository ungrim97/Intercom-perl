use Log::Any::Adapter qw/TAP/;
use JSON;
use Test::Most tests => 3;
use Test::MockObject;

use Intercom::Client;
my $client = Intercom::Client->new({ auth_token => 'token', ua => Test::MockObject->new() });

subtest 'Invalid token' => sub {
    $client->ua->mock(request => sub {
        return HTTP::Response->new(
            '401',
            'Unauthorized',
            [ 'Content-type' => 'application/json' ],
            '{"type":"error.list","request_id":"0008pcfj9dh1eig57qv0","errors":[{"code":"token_unauthorized","message":"Unauthorized"}]}');
    });

    my ($user_data, $error) = $client->users->create({email => 'test@test.com'});

    cmp_deeply(
        $error,
        {
            type => 'error.list',
            request_id => '0008pcfj9dh1eig57qv0',
            errors => [{
                code => 'token_unauthorized',
                message => 'Unauthorized'
            }]
        },
        'Error returned correctly'
    );
};

subtest 'Network issue' => sub {
    $client->ua->mock(request => sub {
        return HTTP::Response->new(502);
    });

    my ($user_data, $error) = $client->users->create({email => 'test@test.com'});

    cmp_deeply($error, '', 'No error');
};

subtest 'Successful request' => sub {
    $client->ua->mock(request => sub {
        return HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json(_user_data())
        );
    });

    my $user_data = $client->users->create({email => 'test@test.com'});

    cmp_deeply($user_data, _user_data(), 'Correctly returned user data');
};

sub _user_data {
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
      social_profiles => {
        type            => 'social_profile.list',
        social_profiles => [{
            name     => 'twitter',
           id        => '1235d3213',
            username => 'th1sland',
            url      => 'http://twitter.com/th1sland'
        }]
      },
      companies   => {
        type      => 'company.list',
        companies => [{
            id  => '530370b477ad7120001e'
        }]
      },
      segments => {
        type     => 'segment.list',
        segments => [{
            id => '5310d8e7598c9a0b24000002'
        }]
      },
      tags => {
        type => 'tag.list',
        tags => [{
            id => '202'
        }]
      }
    }
}
