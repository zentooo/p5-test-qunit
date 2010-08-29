use strict;
use Test::More;

use Plack::App::Directory;
use Plack::Runner;

use Data::Util qw(:check);

use Test::QUnit;
use Test::QUnit::Bridge::MozRepl;


my $bridge = Test::QUnit::Bridge::MozRepl->new;


subtest('tests for run_test' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        $bridge->hook_qunit_log();

        my $result = $bridge->run_test('http://localhost:8080/index.html');

        $result->{length};
        isnt($result, undef, 'we got a result');
        isnt($result->{length}, undef, 'we got a wrapped array object');

        for ( my $i = 0, my $length = $result->{length}; $i < $length; $i++ ) {
            my $item = $result->[$i];
            isnt($item->{success}, undef, 'item has "success" property');
            isnt($item->{message}, undef, 'item has "message" property');
        }

        $bridge->cleanup();

        system("kill -KILL $pid");
    }
    else {
    # child
        note 'running Plack server for serving QUnit test suite';
        $runner->run($app);
    }

    done_testing;
});


subtest('tests for result_to_tap' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        $bridge->hook_qunit_log();

        my $raw_result = $bridge->run_test('http://localhost:8080/index.html');
        my $tap_result = $bridge->result_to_tap($raw_result);

        for my $result (@$tap_result) {
            ok( $result->{success} == 0 || $result->{success} == 1, 'success flag should be 0 or 1');
            ok( $result->{message} =~ /.*/, 'message should be string');
        }

        $bridge->cleanup();

        system("kill -KILL $pid");
    }
    else {
    # child
        note 'running Plack server for serving QUnit test suite';
        $runner->run($app);
    }

    done_testing;
});


subtest('tests for run_qunit' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        my $tap_result = $bridge->run_qunit('http://localhost:8080/index.html');

        for my $result (@$tap_result) {
            ok( $result->{success} == 0 || $result->{success} == 1, 'success flag should be 0 or 1');
            ok( $result->{message} =~ /.*/, 'message should be string');
        }

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
