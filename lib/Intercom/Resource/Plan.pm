package Intercom::Resource::Plan;

use Moo;

has id   => ( is => 'ro' );
has name => ( is => 'ro' );

sub type { return 'plan' };

1;
