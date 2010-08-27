use strict;
use Test::Most;

use Path::Class;
use Plack::App::Directory;
use Plack::Runner;

use Data::Dumper;

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
    note 'sleep';
    sleep(2);

    isnt($Test::QUnit::tab->{__test__qunit__}->{truth}, undef, 'tab.__test__qunit__.truth exists');
    isnt($Test::QUnit::tab->{__test__qunit__}->{result}->[0], undef, 'tab.__test__qunit__.result has 1');


    # cleanup

    $repl->expr(<<"JS");
     var tab = getBrowser().mTabBox._tabs.childNodes[$Test::QUnit::tab_index];
     delete tab.__test__qunit__.truth;
JS
    Test::QUnit::cleanup();
    isnt($Test::QUnit::tab->{__test__qunit__}->{result}->[0], 1, 'tab.__test__qunit__.result is empty now');

    $Test::QUnit::tab->{linkedBrowser}->reload();
    note 'sleep';
    sleep(2);

    is($Test::QUnit::tab->{__test__qunit__}->{truth}, undef, 'tab.__test__qunit__.truth not exists');

    done_testing;
});


subtest('core methods' => sub {

    # run_test

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(2);

        my $result = Test::QUnit::run_test('http://localhost:8080/index.html');

        isnt($result, undef, 'we got a result');

        #system("kill -KILL $pid");
    }
    else {
    # child
        note 'running Plack server for running QUnit test suite';
        $runner->run($app);
    }

    done_testing;
});


done_testing;
