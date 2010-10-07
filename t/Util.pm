package t::Util;

use Plack::App::Directory;
use Plack::Runner;
use Test::More;

our @EXPORT = qw/run_with_plack/;
use base qw/Exporter/;


my $qunit_test_dir = 't/qunit';


sub run_with_plack(&) {
  my $test = shift;

  my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
  my $runner = Plack::Runner->new;

  my $pid = fork;

  if ( $pid ) {
    # parent
    sleep(1);
    $test->();
    kill 'KILL', $pid;
  }
  else {
    # child
    note 'running Plack server for serving QUnit test suite';
    $runner->run($app);
  }
}

1;
