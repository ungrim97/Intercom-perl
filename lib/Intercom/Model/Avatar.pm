package Intercom::Model::Avatar;

use Moo;

has image_url => ( is => 'ro' );

sub type { return 'avatar' }

1;
