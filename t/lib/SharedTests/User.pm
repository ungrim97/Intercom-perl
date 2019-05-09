package SharedTests::User;
use Test::Most;

sub test_resource_generation {
    my ($resource, $user_data) = @_;

    subtest 'Resource data' => sub {
        plan tests => 50;

        is($resource->type, 'user', 'User resource returned');

        # Basic user resource data
        is($resource->id, $user_data->{'id'}, 'id has correct value');
        is($resource->user_id, $user_data->{'user_id'}, 'user_id has correct value');
        is($resource->email, $user_data->{'email'}, 'email has correct value');
        is($resource->phone, $user_data->{'phone'}, 'phone has correct value');
        is($resource->name, $user_data->{'name'}, 'name has correct value');
        is($resource->updated_at, $user_data->{'updated_at'}, 'updated_at has correct value');
        is($resource->last_seen_ip, $user_data->{'last_seen_ip'}, 'last_seen_ip has correct value');
        is($resource->unsubscribed_from_emails, $user_data->{'unsubscribed_from_emails'}, 'unsubscribed_from_emails has correct value');
        is($resource->last_request_at, $user_data->{'last_request_at'}, 'last_request_at has correct value');
        is($resource->signed_up_at, $user_data->{'signed_up_at'}, 'signed_up_at has correct value');
        is($resource->created_at, $user_data->{'created_at'}, 'created_at has correct value');
        is($resource->session_count, $user_data->{'session_count'}, 'session_count has correct value');
        is($resource->user_agent_data, $user_data->{'user_agent_data'}, 'user_agent_data has correct value');
        is($resource->pseudonym, $user_data->{'pseudonym'}, 'pseudonym has correct value');
        is($resource->anonymous, $user_data->{'anonymous'}, 'anonymous has correct value');
        is($resource->referrer, $user_data->{'referrer'}, 'referrer has correct value');
        is($resource->utm_campaign, $user_data->{'utm_campaign'}, 'utm_campaign has correct value');
        is($resource->utm_content, $user_data->{'utm_content'}, 'utm_content has correct value');
        is($resource->utm_medium, $user_data->{'utm_medium'}, 'utm_medium has correct value');
        is($resource->utm_source, $user_data->{'utm_source'}, 'utm_source has correct value');
        is($resource->utm_term, $user_data->{'utm_term'}, 'utm_term has correct value');

        # User custom attributes
        cmp_deeply($resource->custom_attributes, $user_data->{custom_attributes}, 'custom_attributes has the correct value');

        # Avatar
        is($resource->avatar->type, $user_data->{avatar}{type}, 'User has Avatar resource');
        is($resource->avatar->image_url, $user_data->{avatar}{'image_url'}, 'Avatar->image_url has correct value');

        # Companies
        is($resource->companies->type, $user_data->{companies}{type}, 'User has companies list resource');
        is($resource->companies->companies->[0]->type, $user_data->{companies}{companies}[0]{type}, 'CompanyList has a company resource');
        is($resource->companies->companies->[0]->id, $user_data->{companies}{companies}[0]{'id'}, 'Company->id has correct value');

        # Location data
        is($resource->location_data->type, $user_data->{location_data}{type}, 'User has location data resource');
        is($resource->location_data->city_name, $user_data->{location_data}{city_name}, 'LocationData->city_name has correct value');
        is($resource->location_data->continent_code, $user_data->{location_data}{continent_code}, 'LocationData->continent_code has correct value');
        is($resource->location_data->country_code, $user_data->{location_data}{country_code}, 'LocationData->country_code has correct value');
        is($resource->location_data->country_name, $user_data->{location_data}{country_name}, 'LocationData->country_name has correct value');
        is($resource->location_data->latitude, $user_data->{location_data}{latitude}, 'LocationData->latitude has correct value');
        is($resource->location_data->longitude, $user_data->{location_data}{longitude}, 'LocationData->longitude has correct value');
        is($resource->location_data->postal_code, $user_data->{location_data}{postal_code}, 'LocationData->postal_code has correct value');
        is($resource->location_data->region_name, $user_data->{location_data}{region_name}, 'LocationData->region_name has correct value');
        is($resource->location_data->timezone, $user_data->{location_data}{timezone}, 'LocationData->timezone has correct value');

        # Social Profile data
        is($resource->social_profiles->type, $user_data->{social_profiles}{type}, 'User has a social profiles list resource');
        is($resource->social_profiles->social_profiles->[0]->type, $user_data->{social_profiles}{social_profiles}[0]{type}, 'SocialProfileList has a social profile resource');
        is($resource->social_profiles->social_profiles->[0]->name, $user_data->{social_profiles}{social_profiles}[0]{name}, 'SocialProfile->name has correct value');
        is($resource->social_profiles->social_profiles->[0]->id, $user_data->{social_profiles}{social_profiles}[0]{id}, 'SocialProfile->id has correct value');
        is($resource->social_profiles->social_profiles->[0]->username, $user_data->{social_profiles}{social_profiles}[0]{username}, 'SocialProfile->username has correct value');
        is($resource->social_profiles->social_profiles->[0]->url, $user_data->{social_profiles}{social_profiles}[0]{url}, 'SocialProfile->url has correct value');

        # Segments
        is($resource->segments->type, 'segment.list', 'User has a segments list resource');
        is($resource->segments->segments->[0]->type, $user_data->{segments}{segments}[0]{type}, 'SegmentList has a segment resource');
        is($resource->segments->segments->[0]->id, $user_data->{segments}{segments}[0]{id}, 'Segment->id has correct value');

        # Tag
        is($resource->tags->type, 'tag.list', 'User has a tags list resource');
        is($resource->tags->tags->[0]->type, $user_data->{tags}{tags}[0]{type}, 'TagList has a tag resource');
        is($resource->tags->tags->[0]->id, $user_data->{tags}{tags}[0]{id}, 'Tag->id has correct value');
    };
}

1;
