use lib 't/lib';

use JSON;
use Test::Most tests => 4;
use Test::MockObject;
use Test::Mock::LWP::Dispatch;
use SharedTests::Request;
use SharedTests::Company;

use Intercom::Client;

SharedTests::Request::all_tests(sub {
    return shift->companies->get(1);
});

subtest 'search' => sub {
    plan tests => 2;

    subtest 'Segment_id' => sub {
        my $company_data = company_data();

        my $mock_ua = LWP::UserAgent->new();
        $mock_ua->map(qr#/companies\?segment_id=1234$# => sub {
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

        my $resource = $client->companies->search({segment_id => 1234});
        SharedTests::Company::test_resource_generation($resource->companies->[0], $company_data->{companies}[0]);
    };

    subtest 'tag_id' => sub {
        my $company_data = company_data();

        my $mock_ua = LWP::UserAgent->new();
        $mock_ua->map(qr#/companies\?tag_id=123$# => sub {
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

        my $resource = $client->companies->search({tag_id => 123});
        SharedTests::Company::test_resource_generation($resource->companies->[0], $company_data->{companies}[0]);
    };
};

subtest 'duplicate params' => sub {
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

    my $resource = $client->companies->search({tag_id => 123, segment_id => 1234});
    is($resource->errors->[0]{code}, 'parameter_invalid', 'Invalid param error returned');
};

subtest 'pagination' => sub {
    plan tests => 2;

    my $company_data = company_data();
    my $company_data2 = company_data();
    delete $company_data2->{pages}{next};
    $company_data2->{companies}[0]{id} = '530370b477ad7120002d';

    my @data = ($company_data, $company_data2);

    my $mock_ua = LWP::UserAgent->new();
    $mock_ua->map(qr#/companies\?segment_id=1234$# => sub {
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
    $mock_ua->map(qr#/companies\?segment_id=1234&per_page=1&page=2$# => sub {
        my ($request) = @_;
        my $response = HTTP::Response->new(
            '200',
            'OK',
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($company_data2)
        );

        $response->request($request);
        return $response;
    });

    my $client = Intercom::Client->new({
        access_token => 'test',
        ua           => $mock_ua
    });

    my $userlist = $client->companies->search({segment_id => 1234});
    do {
        SharedTests::Company::test_resource_generation($userlist->companies->[0], shift(@data)->{companies}[0]);
    } while ($userlist = $userlist->pages->get_next());
};

sub company_data {
	return {
        type => 'company.list',
        total_count => 2,
        pages => {
            type => 'page',
            next => 'https://api.intercom.io/companies?segment_id=1234&per_page=1&page=2',
            total_pages => 2,
        },
        companies => [{
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
        }],
    };
}
