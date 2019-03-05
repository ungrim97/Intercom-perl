package Intercom::Resource::SocialProfile;

use Moo;

has name     => ( is => 'ro' );
has id       => ( is => 'ro' );
has username => ( is => 'ro' );
has url      => ( is => 'ro' );

sub type { return 'social_profile' }

1;
