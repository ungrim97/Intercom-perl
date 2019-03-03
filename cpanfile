requires 'perl', '5.008001';
requires 'JSON';
requires 'LWP::UserAgent';
requires 'Module::Runtime';
requires 'Moo';
requires 'URI';

on 'test' => sub {
    requires 'Test::Most';
    requires 'Test::MockObject';
    requires 'Try::Tiny';
};
