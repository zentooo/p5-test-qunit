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

  test_with_plack {
    my $port = shift;
    qunit_ok("http://localhost:$port/index.html");
  };

});

subtest('tests for qunit_remote' => sub {

  test_with_plack {
    my $port = shift;
    qunit_remote("http://localhost:$port/index.html");
  };

});


subtest('tests for qunit_local' => sub {

  qunit_local('t/qunit/index.html');

  done_testing;
});


# close created tab

$repl->expr(<<"JS");
  var tabs = getBrowser().tabs;
  tabs[tabs.length - 1].linkedBrowser.contentWindow.close();
  tabs[tabs.length - 1].linkedBrowser.contentWindow.close();
JS


done_testing;
