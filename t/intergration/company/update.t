use lib 't/lib';

use JSON;
use Test::Most tests => 3;
use Test::MockObject;
use Test::Mock::LWP::Dispatch;
use SharedTests::Request;
use SharedTests::Company;

use Intercom::Client;

SharedTests::Request::all_tests(sub {
    return shift->companies->update({company_id => 6, name => 'Black Sun'});
});

subtest 'missing param' => sub {
    plan tests => 1;

    my $company_data = company_data();

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#^.*$#, sub {
        fail('called through to UA')
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $resource = $client->companies->update();
    is($resource->errors->[0]{code}, 'parameter_not_found', 'Missing param error returned');
};

subtest 'update company' => sub {
    plan tests => 4;

    my $company_data = company_data();
    my $update_data = {
        remote_create_at  => 1397574667,
        company_id        => 6,
        name              => 'Black Sun',
        plan              => 'plan1',
        size              => 85,
        website           => "http://www.example.com",
        industry          => "Manufacturing",
        monthly_spend     => 49,
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
            cmp_deeply(JSON::decode_json($request->content()), $update_data, 'Request has correct data');

            return like($request->uri(), qr#/companies$#, 'Request has correct URI');
        },
        sub {
            my ($request) = @_;
            my $response = HTTP::Response->new(
                '200',
                'OK',
                [ 'Content-Type' => 'application/json' ],
                JSON::encode_json($company_data)
            );

            $response->request($request);
            return $response;
        }
    );

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua         => $mock_ua
    });

    my $resource = $client->companies->update($update_data);

    SharedTests::Company::test_resource_generation($resource, $company_data);
};

sub company_data {
	return {
        type                => 'company',
        id                  => '530370b477ad7120001e',
        "name"              => "Blue Sun",
        "plan"              => {
            "type" => "plan",
            "id"   => "123",
            "name" => "plan1",
        },
        "company_id"        => "6",
        "remote_created_at" => 1394531169,
        "created_at"        => 1394533506,
        "updated_at"        => 1396874658,
        "size"              => 85,
        "website"           => "http://www.example.com",
        "industry"          => "Manufacturing",
        "monthly_spend"     => 49,
        "session_count"     => 26,
        "user_count"        => 10,
        "custom_attributes" => {
            "paid_subscriber" => JSON::true,
            "team_mates"      => 0
        },
        "segments" => {
            "segments" => [{
                "id"         => "1234",
                "name"       => "Segment Name",
                "created_at" => 1394531169,
                "updated_at" => 1394531169,
                "type"       => "segment",
                "count"      => 1,
            }],
            "type" => "segment.list"
        },
        "tags" => {
            "tags" => [{
                "id"   => "1234",
                "name" => "tag name",
                "type" => "tag",
            }],
            "type" => "tag.list"
        }
    };
}
