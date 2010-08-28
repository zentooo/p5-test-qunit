use strict;
use Test::More;

BEGIN { use_ok 'Test::QUnit::Bridge::MozRepl' }

my $bridge = Test::QUnit::Bridge::MozRepl->new;

subtest('accessors test' => sub {

    ok($bridge->{tab_index} =~ /\d+/, 'tab index is number');
    is($bridge->{tab}->{_tPos}, $bridge->{tab_index}, 'given tab index is equal to tab_index');

    done_testing;
});

subtest('JS Objects in opened tab are initialized successfully' => sub {

    is($bridge->{tab}->{hoge}, undef, 'tab.hoge not exists');
    isnt($bridge->{tab}->{__test__qunit__}, undef, 'tab.__test__qunit__ exists');
    isnt($bridge->{tab}->{__test__qunit__}->{result}, undef, 'tab.__test__qunit__.result exists');
    isnt($bridge->{tab}->{__test__qunit__}->{listener}, undef, 'tab.__test__qunit__.result exists');

    done_testing;
});


done_testing;
