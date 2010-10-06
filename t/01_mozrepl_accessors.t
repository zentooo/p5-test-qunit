use strict;
use Test::More;

use MozRepl;
use MozRepl::RemoteObject;
use Data::Util qw/:check/;

BEGIN { use_ok 'Test::QUnit::Bridge::MozRepl' }


my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);
my $bridge = Test::QUnit::Bridge::MozRepl->new;


subtest('accessors test' => sub {

    ok( is_number($bridge->{tab_index}), 'tab index is number');
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


# close created tab

$repl->expr(<<"JS");
  getBrowser().tabs[$bridge->{tab_index}].linkedBrowser.contentWindow.close();
JS

done_testing;
