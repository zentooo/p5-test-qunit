package Test::QUnit::Bridge::MozRepl;

use strict;
use warnings;

use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw(tab tab_index bridge));

use MozRepl;
use MozRepl::RemoteObject;

use Time::HiRes qw(sleep);
use Data::Util qw(:check);


sub new {
    my ($class, $repl) = @_;
    my $r = $repl || MozRepl->new;
    my $bridge = MozRepl::RemoteObject->install_bridge($r);
    my $tab = $bridge->expr("getBrowser().addTab('http://google.com')");
    my $tab_index = $tab->{_tPos};
    my $tab_obj = "getBrowser().mTabBox._tabs.childNodes[$tab_index]";
    my $qunit_obj = "$tab_obj.__test__qunit__";

    $bridge->expr(<<"JS");
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
    return $class->SUPER::new(+{
        bridge => $bridge,
        tab => $tab,
        tab_index => $tab_index,
        tab_obj => $tab_obj,
        qunit_obj => $qunit_obj,
    });
}

sub inject_bridge {
    my ($self, $repl) = @_;
    $self->bridge(MozRepl::RemoteObject->install_bridge($repl));
}

sub result_to_tap {
    my ($self, $result) = @_;

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
    my ($self, $url) = @_;

    $self->hook_qunit_log();

    $self->{bridge}->expr(<<"JS");
    $self->{tab_obj}.linkedBrowser.contentWindow.location = '$url';
JS

    my $done = $self->{bridge}->expr(<<"JS");
    $self->{qunit_obj}.done;
JS

    while ( $done eq 'false' ) {
        sleep(0.5);
        $done = $self->{bridge}->expr(<<"JS");
        $self->{qunit_obj}.done;
JS
    }

    return $self->{tab}->{__test__qunit__}->{result};
}

sub inject_select_window_function {
    my ($self, $js) = @_;

    $self->{bridge}->expr(<<"JS");
    $self->{qunit_obj}.selectWindow = $js;
JS
}

sub hook_qunit_log {
    my $self = shift;
    $self->{bridge}->expr(<<"JS");
    getBrowser().addEventListener('load', $self->{qunit_obj}.listener, true);
JS
}

sub cleanup {
    my $self = shift;
    $self->{bridge}->expr(<<"JS");
    getBrowser().removeEventListener('load', $self->{qunit_obj}.listener, true);
    $self->{qunit_obj}.result = [];
    $self->{qunit_obj}.done = false;
JS
}


1;
