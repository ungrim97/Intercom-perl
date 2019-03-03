package Intercom::Model::ErrorList;

use Moo;

has errors => ( is => 'ro', required => 1 );

sub type { return 'error.list' }

1;
