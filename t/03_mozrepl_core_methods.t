use strict;
use Test::More;

use Data::Util qw(:check);

use Test::QUnit::Bridge::MozRepl;
use t::Util;


my $r = MozRepl->new;
my $repl = MozRepl::RemoteObject->install_bridge($r);
my $bridge = Test::QUnit::Bridge::MozRepl->new;


subtest('tests for run_test' => sub {

    test_with_plack {
      my $port = shift;

      $bridge->hook_qunit_log();

      my $result = $bridge->run_test("http://localhost:$port/index.html");

      $result->{length};
      isnt($result, undef, 'we got a result');
      isnt($result->{length}, undef, 'we got a wrapped array object');

      for ( my $i = 0, my $length = $result->{length}; $i < $length; $i++ ) {
        my $item = $result->[$i];
        isnt($item->{success}, undef, 'item has "success" property');
        isnt($item->{message}, undef, 'item has "message" property');
      }

      $bridge->cleanup();

      done_testing;
    };

});


subtest('tests for result_to_tap' => sub {

    test_with_plack {
      my $port = shift;

      $bridge->hook_qunit_log();

      my $raw_result = $bridge->run_test("http://localhost:$port/index.html");
      my $tap_result = $bridge->result_to_tap($raw_result);

      for my $result (@$tap_result) {
          ok( $result->{success} == 0 || $result->{success} == 1, 'success flag should be 0 or 1');
          ok( is_string($result->{message} || $result->{message} eq ""), 'message should be string');
      }

      $bridge->cleanup();

      done_testing;
    };

});


subtest('tests for run_qunit' => sub {

    test_with_plack {
      my $port = shift;

      my $tap_result = $bridge->run_qunit("http://localhost:$port/index.html");

      for my $result (@$tap_result) {
          ok( $result->{success} == 0 || $result->{success} == 1, 'success flag should be 0 or 1');
          ok( is_string($result->{message} || $result->{message} eq ""), 'message should be string');
      }

      done_testing;
    };

});


# close created tab

$repl->expr(<<"JS");
  getBrowser().tabs[$bridge->{tab_index}].linkedBrowser.contentWindow.close();
JS

done_testing;
