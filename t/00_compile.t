use strict;
use Test::More 0.98;

use_ok $_ for qw(
    Intercom::Client
    Intercom::Client::User
    Intercom::Client::RequestHandler
    Intercom::Resource::Admin
    Intercom::Resource::Avatar
    Intercom::Resource::Company
    Intercom::Resource::CompanyList
    Intercom::Resource::ErrorList
    Intercom::Resource::LocationData
    Intercom::Resource::Page
    Intercom::Resource::Segment
    Intercom::Resource::SegmentList
    Intercom::Resource::SocialProfile
    Intercom::Resource::SocialProfileList
    Intercom::Resource::Tag
    Intercom::Resource::TagList
    Intercom::Resource::User
    Intercom::Resource::UserList
);

done_testing;

