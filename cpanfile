requires 'perl', '5.008001';
requires 'JSON';
requires 'LWP::UserAgent';
requires 'Module::Runtime';
requires 'Moo';
requires 'URI';

on 'test' => sub {
    requires 'Test::Mock::LWP::Dispatch';
    requires 'Test::Most';
    requires 'Test::MockObject';
    requires 'Test::MockObject::Extends';
    requires 'Try::Tiny';
};
