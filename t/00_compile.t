use strict;
use Test::More 0.98;

use_ok $_ for qw(
    Intercom::Client
    Intercom::Client::User
    Intercom::Client::RequestHandler
    Intercom::Model::Admin
    Intercom::Model::Avatar
    Intercom::Model::Company
    Intercom::Model::CompanyList
    Intercom::Model::ErrorList
    Intercom::Model::LocationData
    Intercom::Model::Page
    Intercom::Model::Segment
    Intercom::Model::SegmentList
    Intercom::Model::SocialProfile
    Intercom::Model::SocialProfileList
    Intercom::Model::Tag
    Intercom::Model::TagList
    Intercom::Model::User
    Intercom::Model::UserList
);

done_testing;

