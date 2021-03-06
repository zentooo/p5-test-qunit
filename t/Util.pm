package t::Util;

use Plack::App::Directory;
use Plack::Loader;
use Test::More;
use Test::TCP;

our @EXPORT = qw/test_with_plack/;
use base qw/Exporter/;


my $qunit_test_dir = 't/qunit';


sub test_with_plack(&) {
  my $test_code = shift;

  test_tcp(
    client => sub {
      $test_code->(shift);
      done_testing;
    },
    server => sub {
      my $app = Plack::App::Directory->new( root => $qunit_test_dir )->to_app;
      my $server = Plack::Loader->auto(
        port => shift,
        host => '127.0.0.1',
      );
      $server->run($app);

      note 'running Plack server for serving QUnit test suite';
    }
  );
}


1;
