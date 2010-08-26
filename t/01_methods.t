use strict;
use Test::Most;

use Test::QUnit;

my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);


subtest('sub methods' => sub {

    $repl->expr(<<"JS");
     var tab = getBrowser().mTabBox._tabs.childNodes[$Test::QUnit::tab_index];
     delete tab.__test__qunit__.truth;
JS


    # inject_select_window_function

    Test::QUnit::inject_select_window_function("function() {
        var tab = getBrowser().mTabBox._tabs.childNodes[$Test::QUnit::tab_index];
        tab.__test__qunit__.truth = function() { return 'Test::QUnit so awesome!'; };
        tab.__test__qunit__.result.push(1);
        return true;
    }");
    isnt($Test::QUnit::tab->{__test__qunit__}->{selectWindow}, undef, 'tab.__test__qunit__.selectWindow exists');


    # hook_qunit_log

    Test::QUnit::hook_qunit_log();
    $Test::QUnit::tab->{linkedBrowser}->reload();
    isnt($Test::QUnit::tab->{__test__qunit__}->{truth}, undef, 'tab.__test__qunit__.truth exists');
    isnt($Test::QUnit::tab->{__test__qunit__}->{result}->[0], undef, 'tab.__test__qunit__.result has 1');


    # cleanup

    #$repl->expr(<<"JS");
     #var tab = getBrowser().mTabBox._tabs.childNodes[$Test::QUnit::tab_index];
     #delete tab.__test__qunit__.truth;
#JS
    #Test::QUnit::cleanup();

    #$Test::QUnit::tab->{linkedBrowser}->reload();
    #is($Test::QUnit::tab->{__test__qunit__}->{truth}, undef, 'tab.__test__qunit__.truth not exists');
    #isnt($Test::QUnit::tab->{__test__qunit__}->{result}->[0], 1, 'tab.__test__qunit__.result is empty now');

    done_testing;
});


done_testing;
