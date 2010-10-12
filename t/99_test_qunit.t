use strict;
use Test::More;

use MozRepl;
use MozRepl::RemoteObject;

use Test::QUnit;
use t::Util;

my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);


BEGIN { use_ok 'Test::QUnit' }


subtest('exported methods' => sub {

    can_ok('main', qw/inject_bridge select_test_window select_onload_window onload qunit_remote qunit_local_html/);

    done_testing;
});


subtest('tests for qunit_ok' => sub {

    run_with_plack {

        qunit_ok('http://localhost:8080/index.html');

        done_testing;
    };

});

subtest('tests for qunit_remote' => sub {

    run_with_plack {

        qunit_remote('http://localhost:8080/index.html');

        done_testing;
    };

});


subtest('tests for qunit_local_html' => sub {

    qunit_local('t/qunit/index.html');

    qunit_local_html('t/qunit/index.html');

    done_testing;
});


# close created tab

$repl->expr(<<"JS");
  var tabs = getBrowser().tabs;
  tabs[tabs.length - 1].linkedBrowser.contentWindow.close();
  tabs[tabs.length - 1].linkedBrowser.contentWindow.close();
JS


done_testing;
