package Intercom::Resource::TagList;

use Moo;

has tags => ( is => 'ro' );

sub type { return 'tag.list'; }

1;
