use strict;
use Test::More;

use MozRepl;
use MozRepl::RemoteObject;

use Test::QUnit::Bridge::MozRepl;

my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);
my $bridge = Test::QUnit::Bridge::MozRepl->new;


subtest('tests for inject_select_test_window_function' => sub {

    $repl->expr(<<"JS");
     var tab = getBrowser().tabs[$bridge->{tab_index}];
     delete tab.__test__qunit__.truth;
JS

    $bridge->inject_select_test_window_function("function() {
        var tab = getBrowser().tabs[$bridge->{tab_index}];
        tab.__test__qunit__.truth = function() { return 'Test::QUnit so awesome!'; };
        tab.__test__qunit__.result.push(1);
        return true;
    }");
    isnt($bridge->{tab}->{__test__qunit__}->{selectTestWindow}, undef, 'tab.__test__qunit__.selectTestWindow exists');

    done_testing;
});


subtest('tests for hook_qunit_log' => sub {

    $bridge->hook_qunit_log();

    $bridge->{tab}->{linkedBrowser}->reload();
    note 'sleep for reload';
    sleep(1);

    isnt($bridge->{tab}->{__test__qunit__}->{truth}, undef, 'tab.__test__qunit__.truth exists');
    isnt($bridge->{tab}->{__test__qunit__}->{result}->[0], undef, 'tab.__test__qunit__.result has 1');

    done_testing;
});


subtest('tests for inject_select_onload_window_function' => sub {

    $repl->expr(<<"JS");
     var tab = getBrowser().tabs[$bridge->{tab_index}];
     delete tab.__test__qunit__.onload;
JS

    $bridge->inject_select_onload_window_function("function() {
        return true;
    }");
    isnt($bridge->{tab}->{__test__qunit__}->{selectOnloadWindow}, undef, 'tab.__test__qunit__.selectOnloadWindow exists');


    done_testing;
});


subtest('tests for inject_onload_function' => sub {

    $bridge->inject_onload_function("function(window) {
      var tab = getBrowser().tabs[$bridge->{tab_index}];
        tab.__test__qunit__.lie = function() { return 'Test::QUnit is so awful...'; };
    }");
    isnt($bridge->{tab}->{__test__qunit__}->{onload}, undef, 'tab.__test__qunit__.selectOnloadWindow exists');


    # fire onload event

    $bridge->{tab}->{linkedBrowser}->reload();
    note 'sleep for reload';
    sleep(1);

    isnt($bridge->{tab}->{__test__qunit__}->{lie}, undef, 'tab.__test__qunit__.lie exists');

    done_testing;
});


subtest('tests for cleanup' => sub {

    $repl->expr(<<"JS");
     var tab = getBrowser().tabs[$bridge->{tab_index}];
     delete tab.__test__qunit__.truth;
JS
    $bridge->cleanup();
    isnt($bridge->{tab}->{__test__qunit__}->{result}->[0], 1, 'tab.__test__qunit__.result is empty now');

    $bridge->{tab}->{linkedBrowser}->reload();
    note 'sleep';
    sleep(2);

    is($bridge->{tab}->{__test__qunit__}->{truth}, undef, 'tab.__test__qunit__.truth not exists');

    done_testing;
});


# close created tab

$repl->expr(<<"JS");
  getBrowser().tabs[$bridge->{tab_index}].linkedBrowser.contentWindow.close();
JS

done_testing;
