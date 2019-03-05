package Intercom::Resource::SocialProfileList;

use Moo;

has social_profiles => ( is => 'ro' );

sub type { return 'social_profile.list' }

1;
