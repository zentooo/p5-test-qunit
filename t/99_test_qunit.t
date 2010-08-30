use strict;
use Test::More;

use Plack::App::Directory;
use Plack::Runner;

use MozRepl;


BEGIN { use_ok 'Test::QUnit' }

use Test::QUnit;

subtest('inject_bridge' => sub {

    inject_bridge('MozRepl' => MozRepl->new);
    ok(1);
    done_testing;
});

subtest('inject_select_window_function' => sub {

    inject_select_window_function("function() {
        return true;
    }");
    ok(1);
    done_testing;
});

subtest('tests for qunit_ok' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        qunit_ok('http://localhost:8080/index.html');

        system("kill -KILL $pid");
    }
    else {
    # child
        note 'running Plack server for serving QUnit test suite';
        $runner->run($app);
    }

    done_testing;
});

done_testing;
