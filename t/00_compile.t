use strict;
use Test::More;
use MozRepl;

BEGIN { use_ok 'Test::QUnit' }


subtest('inject_bridge' => sub {

    Test::QUnit::inject_bridge('MozRepl' => MozRepl->new);
    ok(1);
    done_testing;
});

subtest('inject_select_window_function' => sub {

    Test::QUnit::inject_select_window_function("function() {
        return true;
    }");
    ok(1);
    done_testing;
});


done_testing;
