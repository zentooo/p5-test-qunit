use strict;
use Test::More;

use Plack::App::Directory;
use Plack::Runner;

use MozRepl;
use MozRepl::RemoteObject;

my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);


BEGIN { use_ok 'Test::QUnit' }

subtest('exported methods' => sub {

    can_ok('main', qw/inject_bridge select_test_window select_onload_window onload qunit_ok/);

    done_testing;
});


my $qunit_test_dir = 't/qunit';

subtest('tests for qunit_ok' => sub {

    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        qunit_ok('http://localhost:8080/index.html');

        system("kill -KILL $pid");

        done_testing;
    }
    else {
    # child
        note 'running Plack server for serving QUnit test suite';
        $runner->run($app);
    }

});


# close created tab

$repl->expr(<<"JS");
  var tabs = getBrowser().tabs;
  tabs[tabs.length - 1].linkedBrowser.contentWindow.close();
JS


done_testing;
