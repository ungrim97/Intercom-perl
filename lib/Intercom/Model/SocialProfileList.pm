package Intercom::Model::SocialProfileList;

use Moo;

has social_profiles => ( is => 'ro' );

sub type { return 'social_profile.list' }

1;
