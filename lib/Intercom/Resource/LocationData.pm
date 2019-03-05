package Intercom::Resource::LocationData;

use Moo;

has city_name      => ( is => 'ro' );
has continent_code => ( is => 'ro' );
has country_code   => ( is => 'ro' );
has country_name   => ( is => 'ro' );
has latitude       => ( is => 'ro' );
has longitude      => ( is => 'ro' );
has postal_code    => ( is => 'ro' );
has region_name    => ( is => 'ro' );
has timezone       => ( is => 'ro' );

sub type { return 'location_data' }

1;
