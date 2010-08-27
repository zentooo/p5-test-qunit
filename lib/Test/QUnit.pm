package Test::QUnit;
use strict;
use warnings;
our $VERSION = '0.01';

my $CLASS = __PACKAGE__;

use base qw(Test::Builder::Module);

use MozRepl;
use MozRepl::RemoteObject;

our @EXPORT = qw(url_ok);

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

        tab.__test__qunit__.listener = function(event) {
            var target = event.originalTarget;

            if ( target instanceof HTMLDocument ) {
                var wrappedWindow = target.defaultView;
                var isWantedWindow = true;

                if ( typeof tab.__test__qunit__.selectWindow === "function" ) {
                    isWantedWindow = tab.__test__qunit__.selectWindow();
                    tab.linkedBrowser.contentWindow.alert(inWantedWindow);
                }

                if ( isWantedWindow ) {
                    wrappedWindow.addEventListener("load", function(event) {
                        var window = event.originalTarget.wrappedJSObject;
                        window.QUnit.log = function(a, msg) {
                            tab.__test__qunit__.result.push( { success: a, message: msg } );
                        };
                    }, false);
                }
            }
        };
    })();
JS
}


sub url_ok($;$) {
    my ($url, $msg) = @_;

}

sub run_test {
    my $url = shift;

    hook_qunit_log();

    $repl->expr(<<"JS");
    $tab_obj.linkedBrowser.contentWindow.location = '$url';
JS

    my $result = $tab->{__test__qunit__}->{result};

    cleanup();

    return $result;
}

sub inject_select_window_function {
    my $js = shift;
    print $js;
    print $qunit_obj;

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
JS
}


1;
__END__

=head1 NAME

Test::QUnit - execute QUnit with TAP, via mozrepl.

=head1 SYNOPSIS

  use Test::QUnit;

=head1 DESCRIPTION

Test::QUnit is

=head1 AUTHOR

zentooo E<lt>ankerasoy@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
