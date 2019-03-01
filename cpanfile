requires 'perl', '5.008001';
requires 'JSON';
requires 'Log::Any';
requires 'LWP::UserAgent';
requires 'Moo';
requires 'URI';

on 'test' => sub {
    requires 'Log::Any::Adapter::TAP';
    requires 'Test::Most';
    requires 'Test::MockObject';
    requires 'Try::Tiny';
};
