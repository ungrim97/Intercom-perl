use JSON;
use Test::Most tests => 3;
use Test::MockObject;
use Test::Mock::LWP::Dispatch;
use SharedTests::Request;

use Intercom::Client;

SharedTests::Request::auth_failure(sub {
    return shift->users->create({email => 'test@test.com'});
});

SharedTests::Request::connection_failure(sub {
    return shift->users->create({email => 'test@test.com'});
});

subtest 'create user' => sub {
    plan tests => 4;

    my $user_data = user_data();
    my $create_data = {
        user_id                  => '25',
        email                    => 'wash@serenity.io',
        phone                    => '+1123456789',
        name                     => 'Hoban Washburne',
        last_seen_ip             => '1.2.3.4',
        unsubscribed_from_emails => JSON::false,
        last_request_at          => 1397574667,
        last_seen_user_agent_    => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9',
        last_request_at          => 1397574667,
        companies                => [{
            id => '530370b477ad7120001e'
        }],
        custom_attributes => {
            paid_subscriber => JSON::true,
            monthly_spend   => 155.5,
            team_mates      => 1
        },
    };

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(
        sub {
            my ($request) = @_;

            is($request->method, 'POST', 'Request has correct HTTP Verb');
            cmp_deeply(JSON::decode_json($request->content()), $create_data, 'Request has correct data');

            return like($request->uri(), qr#/users$#, 'Request has correct URI');
        },
        HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($user_data)
        )
    );

    my $client = Intercom::Client->new({
        auth_token => 'test',
        ua         => $mock_ua
    });

    my $user = $client->users->create({
        user_id                  => '25',
        email                    => 'wash@serenity.io',
        phone                    => '+1123456789',
        name                     => 'Hoban Washburne',
        last_seen_ip             => '1.2.3.4',
        unsubscribed_from_emails => JSON::false,
        last_request_at          => 1397574667,
        last_seen_user_agent_    => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9',
        last_request_at          => 1397574667,
        companies                => [{
            id => '530370b477ad7120001e'
        }],
        custom_attributes => {
            paid_subscriber => JSON::true,
            monthly_spend   => 155.5,
            team_mates      => 1
        },
    });

    test_model_generation($user, $user_data);
};

sub test_model_generation {
    my ($model, $user_data) = @_;

    subtest 'Model data' => sub {
        is($model->type, 'user', 'User model returned');

        # Basic user model data
        is($model->id, $user_data->{'id'}, 'id has correct value');
        is($model->user_id, $user_data->{'user_id'}, 'user_id has correct value');
        is($model->email, $user_data->{'email'}, 'email has correct value');
        is($model->phone, $user_data->{'phone'}, 'phone has correct value');
        is($model->name, $user_data->{'name'}, 'name has correct value');
        is($model->updated_at, $user_data->{'updated_at'}, 'updated_at has correct value');
        is($model->last_seen_ip, $user_data->{'last_seen_ip'}, 'last_seen_ip has correct value');
        is($model->unsubscribed_from_emails, $user_data->{'unsubscribed_from_emails'}, 'unsubscribed_from_emails has correct value');
        is($model->last_request_at, $user_data->{'last_request_at'}, 'last_request_at has correct value');
        is($model->signed_up_at, $user_data->{'signed_up_at'}, 'signed_up_at has correct value');
        is($model->created_at, $user_data->{'created_at'}, 'created_at has correct value');
        is($model->session_count, $user_data->{'session_count'}, 'session_count has correct value');
        is($model->user_agent_data, $user_data->{'user_agent_data'}, 'user_agent_data has correct value');
        is($model->pseudonym, $user_data->{'pseudonym'}, 'pseudonym has correct value');
        is($model->anonymous, $user_data->{'anonymous'}, 'anonymous has correct value');
        is($model->referrer, $user_data->{'referrer'}, 'referrer has correct value');
        is($model->utm_campaign, $user_data->{'utm_campaign'}, 'utm_campaign has correct value');
        is($model->utm_content, $user_data->{'utm_content'}, 'utm_content has correct value');
        is($model->utm_medium, $user_data->{'utm_medium'}, 'utm_medium has correct value');
        is($model->utm_source, $user_data->{'utm_source'}, 'utm_source has correct value');
        is($model->utm_term, $user_data->{'utm_term'}, 'utm_term has correct value');

        # User custom attributes
        cmp_deeply($model->custom_attributes, $user_data->{custom_attributes}, 'custom_attributes has the correct value');

        # Avatar
        is($model->avatar->type, 'avatar', 'User has Avatar resource');
        is($model->avatar->image_url, $user_data->{avatar}{'image_url'}, 'Avatar->image_url has correct value');

        # Companies
        is($model->companies->type, 'company.list', 'User has companies list resource');
        is($model->companies->companies->[0]->type, 'company', 'CompanyList has a company resource');
        is($model->companies->companies->[0]->id, $user_data->{companies}{companies}[0]{'id'}, 'Company->id has correct value');
    };
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
