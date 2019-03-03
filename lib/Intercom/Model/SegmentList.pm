package Intercom::Model::SegmentList;

use Moo;

has segments => ( is => 'ro' );
has pages    => ( is => 'ro' );

sub type { return 'segment.list' }

1;
