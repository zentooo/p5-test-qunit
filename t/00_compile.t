use strict;
use Test::More;

BEGIN { use_ok 'Test::QUnit' }


subtest('accessors test' => sub {

    ok($Test::QUnit::tab_index =~ /\d+/, 'tab index is number');
    is($Test::QUnit::tab->{_tPos}, $Test::QUnit::tab_index, 'given tab index is equal to tab_index');

    done_testing;
});

subtest('JS Objects in opened tab are initialized successfully' => sub {

    is($Test::QUnit::tab->{hoge}, undef, 'tab.hoge not exists');
    isnt($Test::QUnit::tab->{__test__qunit__}, undef, 'tab.__test__qunit__ exists');
    isnt($Test::QUnit::tab->{__test__qunit__}->{result}, undef, 'tab.__test__qunit__.result exists');
    isnt($Test::QUnit::tab->{__test__qunit__}->{listener}, undef, 'tab.__test__qunit__.result exists');

    done_testing;
});



done_testing;
