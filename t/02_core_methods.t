use strict;
use Test::More;

use Plack::App::Directory;
use Plack::Runner;

use Data::Util qw(:check);
use Tie::STDOUT;

use Test::QUnit;


my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);


subtest('tests for run_test' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        my $result = Test::QUnit::run_test('http://localhost:8080/index.html');

        $result->{length};
        isnt($result, undef, 'we got a result');
        isnt($result->{length}, undef, 'we got a wrapped array object');

        for ( my $i = 0, my $length = $result->{length}; $i < $length; $i++ ) {
            my $item = $result->[$i];
            isnt($item->{success}, undef, 'item has "success" property');
            isnt($item->{message}, undef, 'item has "message" property');
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


subtest('tests for result_to_tap' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        my $raw_result = Test::QUnit::run_test('http://localhost:8080/index.html');
        my $tap_result = Test::QUnit::result_to_tap($raw_result);

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


subtest('tests for qunit_ok' => sub {

    my $qunit_test_dir = 'qunit';
    my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
    my $runner = Plack::Runner->new;

    my $pid = fork;

    if ( $pid ) {
    # parent

        sleep(1);

        my @output;

        use Tie::STDOUT print => sub {
            push @output, $_;
        };

        Test::QUnit::qunit_ok('http://localhost:8080/index.html');

        ok(1);

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
