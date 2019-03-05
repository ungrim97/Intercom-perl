package Intercom::Resource::UserList;

use Moo;

has users => ( is => 'ro' );
has pages => ( is => 'ro' );
has total_count => ( is => 'ro' );

sub type { return 'user.list'; }

1;
