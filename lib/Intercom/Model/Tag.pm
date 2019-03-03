package Intercom::Model::Tag;

use Moo;

has id   => ( is => 'ro' );
has name => ( is => 'ro' );

sub type { return 'tag' }

1;
