use lib 't/lib';

use JSON;
use Test::Most tests => 5;
use Test::MockObject;
use Test::Mock::LWP::Dispatch;
use SharedTests::Request;
use SharedTests::Company;

use Intercom::Client;

SharedTests::Request::all_tests(sub {
    return shift->companies->get(1);
});

subtest 'via company_id' => sub {
    plan tests => 1;

    my $company_data = company_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/companies\?company_id=6$# => sub {
        my ($request) = @_;
        my $response = HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($company_data)
        );

        $response->request($request);
        return $response;
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $resource = $client->companies->find({company_id => 6});
    SharedTests::Company::test_resource_generation($resource, $company_data);
};

subtest 'via name' => sub {
    plan tests => 1;

    my $company_data = company_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/companies\?name=Black\+Sun$# => sub {
        my ($request) = @_;
        my $response = HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($company_data)
        );

        $response->request($request);
        return $response;
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $resource = $client->companies->find({name => 'Black Sun'});
    SharedTests::Company::test_resource_generation($resource, $company_data);
};

subtest 'Missing param' => sub {
    my $mock_ua = LWP::UserAgent->new();
    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $errors = $client->companies->find();

    is($errors->errors->[0]{code}, 'parameter_not_found', 'Error returned');
};

subtest 'Duplicate Param' => sub {
    my $mock_ua = LWP::UserAgent->new();
    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $errors = $client->companies->find({company_id => 6, name => 'Black Sun'});

    is($errors->errors->[0]{code}, 'parameter_invalid', 'Error returned');
};

sub company_data {
	return {
        type                => 'company',
        id                  => '530370b477ad7120001e',
        'name'              => 'Blue Sun',
        'plan'              => {
            'type' => 'plan',
            'id'   => '123',
            'name' => 'plan1',
        },
        'company_id'        => '6',
        'remote_created_at' => 1394531169,
        'created_at'        => 1394533506,
        'updated_at'        => 1396874658,
        'size'              => 85,
        'website'           => 'http://www.example.com',
        'industry'          => 'Manufacturing',
        'monthly_spend'     => 49,
        'session_count'     => 26,
        'user_count'        => 10,
        'custom_attributes' => {
            'paid_subscriber' => JSON::true,
            'team_mates'      => 0
        },
        'segments' => {
            'segments' => [{
                'id'         => '1234',
                'name'       => 'Segment Name',
                'created_at' => 1394531169,
                'updated_at' => 1394531169,
                'type'       => 'segment',
                'count'      => 1,
            }],
            'type' => 'segment.list'
        },
        'tags' => {
            'tags' => [{
                'id'   => '1234',
                'name' => 'tag name',
                'type' => 'tag',
            }],
            'type' => 'tag.list'
        }
    };
}
