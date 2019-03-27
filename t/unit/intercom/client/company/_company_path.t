use Test::Most tests => 5;
use Test::MockObject;

use Intercom::Client::Company;
my $company_client = Intercom::Client::Company->new(request_handler => Test::MockObject->new());

subtest 'ID param' => sub {
    plan tests => 1;

    my $uri = $company_client->_company_path({id => 1});

    is($uri->as_string, '/companies/1', 'constructed uri for id');
};

subtest 'company id param' => sub {
    plan tests => 1;

    my $uri = $company_client->_company_path({company_id => 1});

    is($uri->as_string, '/companies?company_id=1', 'constructed uri for company_id');
};

subtest 'tag id param' => sub {
    plan tests => 1;

    my $uri = $company_client->_company_path({tag_id => 1234});

    is($uri->as_string, '/companies?tag_id=1234', 'constructed uri for tag_id');
};

subtest 'segment id param' => sub {
    plan tests => 1;

    my $uri = $company_client->_company_path({segment_id => 1234});

    is($uri->as_string, '/companies?segment_id=1234', 'constructed uri for segment_id');
};

subtest 'no param' => sub {
    plan tests => 1;

    throws_ok(
        sub {$company_client->_company_path()},
        qr/No \[id\], \[name\], \[company_id\], \[tag_id\], or \[segment_id\] provided to identify company/,
        'throws without param'
    );
};
