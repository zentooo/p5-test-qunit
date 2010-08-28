package Test::QUnit;
use strict;
use warnings;
our $VERSION = '0.01';

binmode(STDOUT, ":utf8");

use base qw(Test::Builder::Module);
my $CLASS = __PACKAGE__;

use MozRepl;
use MozRepl::RemoteObject;

use Time::HiRes qw(sleep);
use Data::Util qw(:check);

our @EXPORT = qw(qunit_ok inject_select_window_function);

my $r;
my $repl;

our $tab;
our $tab_index;

my $tab_obj;
my $qunit_obj;

BEGIN {
    $r = MozRepl->new;
    $repl = MozRepl::RemoteObject->install_bridge($r);
    $tab = $repl->expr(<<'JS');
    window.getBrowser().addTab('http://google.com');
JS
    $tab_index = $tab->{_tPos};
    $tab_obj = "getBrowser().mTabBox._tabs.childNodes[$tab_index]";
    $qunit_obj = "$tab_obj.__test__qunit__";

    $repl->expr(<<"JS");
    (function() {
        var tab = $tab_obj;
        tab.__test__qunit__ = {};
        tab.__test__qunit__.result = [];
        tab.__test__qunit__.done = false;

        tab.__test__qunit__.listener = function(event) {
            var target = event.originalTarget;

            if ( target instanceof HTMLDocument ) {
                var wrappedWindow = target.defaultView;
                var isWantedWindow = true;

                if ( typeof tab.__test__qunit__.selectWindow === "function" ) {
                    isWantedWindow = tab.__test__qunit__.selectWindow(wrappedWindow);
                }

                if ( isWantedWindow ) {
                    wrappedWindow.addEventListener("load", function(event) {
                        var window = wrappedWindow.wrappedJSObject;

                        // hook QUnit.log
                        window.QUnit.log = function(a, msg) {
                            if ( typeof a === "boolean" ) {
                                var message;

                                if ( typeof msg === "undefined" || msg === "undefined" ) {
                                    message = '<span class="test-message"></span>nothing<span class="test-expected"></span>';
                                }
                                else {
                                    message = msg;
                                }

                                tab.__test__qunit__.result.push( { success: a, message: message } );
                            }
                        };

                        // hook QUnit.done

                        /* If possible, I want to adopt event-driven solution */
                        //var doneEvent = window.document.createEvent("Event");
                        //doneEvent.initEvent("doneQunitTest", false, true);

                        window.QUnit.done = function(bad, all) {
                            tab.__test__qunit__.done = true;
                            //tab.dispatchEvent("doneQunitTest");
                        };

                    }, false);
                }
            }
        };
    })();
JS
}


sub qunit_ok($;$) {
    my ($url, $diag) = @_;

    my $raw_result = run_test($url);
    my $tap_result = result_to_tap($raw_result);
    cleanup();

    my $builder = $CLASS->builder;

    $builder->subtest($diag => sub {
        for my $result (@$tap_result) {
            $builder->ok($result->{success}, $result->{message});
        }
        $builder->done_testing;
    });
}

sub result_to_tap {
    my $result = shift;

    my @tap_result;

    my $length = $result->{length};
    for ( my $i = 0; $i < $length; $i++ ) {
        my $item = $result->[$i];

        # convert success flag
        my $success = ($item->{success} eq 'true') ? 1 : 0;

        # convert test message
        my $message = "";

        if ( is_string($item->{message}) ) {
            if ( $item->{message} =~ /<span class="test-message">(.*?)<\/span>/ ) {
                $message = $1;
            }
        }

        push(@tap_result, +{ success => $success, message => $message } );
    }

    return \@tap_result;
}

sub run_test {
    my $url = shift;

    hook_qunit_log();

    $repl->expr(<<"JS");
    $tab_obj.linkedBrowser.contentWindow.location = '$url';
JS

    my $done = $repl->expr(<<"JS");
    $qunit_obj.done;
JS

    while ( $done eq 'false' ) {
        sleep(0.5);
        $done = $repl->expr(<<"JS");
        $qunit_obj.done;
JS
    }

    return $tab->{__test__qunit__}->{result};
}

sub inject_select_window_function {
    my $js = shift;

    $repl->expr(<<"JS");
    $qunit_obj.selectWindow = $js;
JS
}

sub hook_qunit_log {
    $repl->expr(<<"JS");
    window.getBrowser().addEventListener('load', $qunit_obj.listener, true);
JS
}

sub cleanup {
    $repl->expr(<<"JS");
    window.getBrowser().removeEventListener('load', $qunit_obj.listener, true);
    $qunit_obj.result = [];
    $qunit_obj.done = false;
JS
}


1;
__END__

=head1 NAME

Test::QUnit - Yet Another Testing Framework for QUnit.

=head1 SYNOPSIS

  use Test::QUnit;

  qunit_ok('http://path/to/qunit/test.html', 'description');

=head1 DESCRIPTION

Test::QUnit is testing framework to run QUnit test suites with prove, via MozRepl.

=head1 AUTHOR

zentooo E<lt>ankerasoy@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
