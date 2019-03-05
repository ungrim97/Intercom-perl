package Intercom::Resource::Segment;

use Moo;

has id         => ( is => 'ro' );
has name       => ( is => 'ro' );
has created_at => ( is => 'ro' );
has updated_at => ( is => 'ro' );
has count      => ( is => 'ro' );

sub type { return 'segment' }

1;
