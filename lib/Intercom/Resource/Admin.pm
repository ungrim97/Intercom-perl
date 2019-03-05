package Intercom::Resource::Admin;

use Moo;

has id                 => (is => 'ro');
has name               => (is => 'ro');
has email              => (is => 'ro');
has job_title          => (is => 'ro');
has away_mode_enabled  => (is => 'ro');
has away_mode_reassign => (is => 'ro');
has has_inbox_seat     => (is => 'ro');
has team_id            => (is => 'ro');
has avatar             => (is => 'ro');

sub type { return 'admin' }

1;
