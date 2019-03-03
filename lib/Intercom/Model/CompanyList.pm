package Intercom::Model::CompanyList;

use Moo;

has companies   => ( is => 'ro' );
has total_count => ( is => 'ro' );
has pages       => ( is => 'ro' );

sub type { return 'company.list' }

1;
