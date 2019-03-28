package SharedTests::Company;
use Test::Most;

sub test_resource_generation {
    my ($resource, $company_data) = @_;

    subtest 'Resource data' => sub {
        plan tests => 22;

        is($resource->type, 'company', 'Company resource returned');

        # Basic user resource data
        is($resource->name, $company_data->{'name'}, 'name has the correct_value');
        is($resource->company_id, $company_data->{'company_id'}, 'company_id has the correct_value');
        is($resource->remote_created_at, $company_data->{'remote_created_at'}, 'remote_created_at has the correct_value');
        is($resource->created_at, $company_data->{'created_at'}, 'created_at has the correct_value');
        is($resource->updated_at, $company_data->{'updated_at'}, 'updated_at has the correct_value');
        is($resource->size, $company_data->{'size'}, 'size has the correct_value');
        is($resource->website, $company_data->{'website'}, 'website has the correct_value');
        is($resource->industry, $company_data->{'industry'}, 'industry has the correct_value');
        is($resource->monthly_spend, $company_data->{'monthly_spend'}, 'monthly_spend has the correct_value');
        is($resource->session_count, $company_data->{'session_count'}, 'session_count has the correct_value');
        is($resource->user_count, $company_data->{'user_count'}, 'user_count has the correct_value');

        # Company custom_attributes
        cmp_deeply($resource->custom_attributes, $company_data->{'custom_attributes'}, 'custom_attributes has the correct value');

        # Plan
        is($resource->plan->type, 'plan', 'Company has plan resource');
        is($resource->plan->name, $company_data->{plan}{name}, 'Plan->name has correct value');
        is($resource->plan->id, $company_data->{plan}{id}, 'Plan->id has correct value');

        # Segments
        is($resource->segments->type, 'segment.list', 'Company has a segments list resource');
        is($resource->segments->segments->[0]->type, $company_data->{segments}{segments}[0]{type}, 'SegmentList has a segment resource');
        is($resource->segments->segments->[0]->id, $company_data->{segments}{segments}[0]{id}, 'Segment->id has correct value');

        # Tags
        is($resource->tags->type, 'tag.list', 'Company has a tags list resource');
        is($resource->tags->tags->[0]->type, $company_data->{tags}{tags}[0]{type}, 'TagList has a tag resource');
        is($resource->tags->tags->[0]->id, $company_data->{tags}{tags}[0]{id}, 'Tag->id has correct value');
    };
}

1;
