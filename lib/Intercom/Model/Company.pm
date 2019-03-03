package Intercom::Model::Company;

use Moo;

has id                => ( is => 'ro' );
has name              => ( is => 'ro' );
has plan              => ( is => 'ro' );
has company_id        => ( is => 'ro' );
has remote_created_at => ( is => 'ro' );
has created_at        => ( is => 'ro' );
has updated_at        => ( is => 'ro' );
has size              => ( is => 'ro' );
has website           => ( is => 'ro' );
has industry          => ( is => 'ro' );
has monthly_spend     => ( is => 'ro' );
has session_count     => ( is => 'ro' );
has user_count        => ( is => 'ro' );
has custom_attributes => ( is => 'ro' );

sub type { return 'company' }

1;
