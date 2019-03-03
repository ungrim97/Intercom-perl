package Intercom::Model::User;

use Moo;

has id                       => ( is => 'ro' );
has user_id                  => ( is => 'ro' );
has email                    => ( is => 'ro' );
has phone                    => ( is => 'ro' );
has name                     => ( is => 'ro' );
has updated_at               => ( is => 'ro' );
has last_seen_ip             => ( is => 'ro' );
has unsubscribed_from_emails => ( is => 'ro' );
has last_request_at          => ( is => 'ro' );
has signed_up_at             => ( is => 'ro' );
has created_at               => ( is => 'ro' );
has session_count            => ( is => 'ro' );
has user_agent_data          => ( is => 'ro' );
has pseudonym                => ( is => 'ro' );
has anonymous                => ( is => 'ro' );
has referrer                 => ( is => 'ro' );
has utm_campaign             => ( is => 'ro' );
has utm_content              => ( is => 'ro' );
has utm_medium               => ( is => 'ro' );
has utm_source               => ( is => 'ro' );
has utm_term                 => ( is => 'ro' );
has custom_attributes        => ( is => 'ro' );
has avatar                   => ( is => 'ro' );
has location_data            => ( is => 'ro' );
has social_profiles          => ( is => 'ro' );
has companies                => ( is => 'ro' );
has segments                 => ( is => 'ro' );
has tags                     => ( is => 'ro' );

sub type { return 'user'; }

1;
